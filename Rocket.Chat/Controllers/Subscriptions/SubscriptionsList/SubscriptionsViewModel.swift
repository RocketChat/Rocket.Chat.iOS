//
//  SubscriptionsViewModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/20/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift
import DifferenceKit

class SubscriptionsViewModel {
    var subscriptions: Results<Subscription>? {
        let results = Subscription.all(onlyJoined: !searchState.isSearching)

        switch SubscriptionsSortingManager.selectedSortingOption {
        case .activity:
            return hasLastMessage ? results?.sortedByLastMessageDate() : results?.sortedByRoomUpdatedAt()
        case .alphabetically:
            return results?.sortedByName()
        }
    }

    enum SearchState {
        case searching(query: String)
        case notSearching

        var isSearching: Bool {
            switch self {
            case .searching:
                return true
            case .notSearching:
                return false
            }
        }
    }

    var searchStateUpdated: ((_ oldValue: SearchState, _ searchState: SearchState) -> Void)?
    var searchState: SearchState = .notSearching {
        didSet {
            searchStateUpdated?(oldValue, searchState)
        }
    }

    var assorter: RealmAssorter<Subscription>? {
        willSet {
            assorter?.invalidate()
        }
    }

    var reloadNotificationToken: NotificationToken?
    let realm: Realm?

    init(realm: Realm? = Realm.current) {
        self.realm = realm
        observeAuth()
    }

    deinit {
        assorter?.invalidate()
    }

    func observeAuth() {
        reloadNotificationToken = realm?.objects(Auth.self).observe({ [weak self] _ in
            if self?.realm?.objects(Auth.self).count == 1 {
                DispatchQueue.main.async {
                    self?.updateVisibleCells?()
                }
            }
        })
    }

    func buildSections() {
        if let realm = realm, assorter == nil {
            assorter = RealmAssorter<Subscription>(realm: realm)
            assorter?.didUpdateIndexPaths = didUpdateIndexPaths
        }

        guard
            let queryBase = subscriptions,
            let assorter = assorter
        else {
            return
        }

        assorter.willReconstructSections()

        switch searchState {
        case .searching(let query):
            let queryData = queryBase.filterBy(name: query)
            assorter.registerSection(name: localized("subscriptions.search_results"), objects: queryData)

            API.current()?.client(SpotlightClient.self).search(query: query) { _, _ in }
            assorter.registerModel(model: queryData)
        case .notSearching:
            var queryItems = queryBase

            func filtered(using predicateFormat: String) -> Results<Subscription> {
                let predicate = NSPredicate(format: predicateFormat)
                let filteredResult = queryItems.filter(predicate)
                queryItems = queryItems.filter(predicate.negation)
                return filteredResult
            }

            if SubscriptionsSortingManager.selectedGroupingOptions.contains(.unread) {
                let queryData = filtered(using: "alert == true")
                assorter.registerSection(name: localized("subscriptions.unreads"), objects: queryData)
            }

            if SubscriptionsSortingManager.selectedGroupingOptions.contains(.favorites) {
                let queryData = filtered(using: "favorite == true")
                assorter.registerSection(name: localized("subscriptions.favorites"), objects: queryData)
            }

            if SubscriptionsSortingManager.selectedGroupingOptions.contains(.type) {
                let queryDataChannels = filtered(using: "privateType == 'c'")
                assorter.registerSection(name: localized("subscriptions.channels"), objects: queryDataChannels)

                let queryDataGroups = filtered(using: "privateType == 'p'")
                assorter.registerSection(name: localized("subscriptions.groups"), objects: queryDataGroups)

                let queryDataDirectMessages = filtered(using: "privateType == 'd'")
                assorter.registerSection(name: localized("subscriptions.direct_messages"), objects: queryDataDirectMessages)
            } else {
                let selectedGroupingOptions = SubscriptionsSortingManager.selectedGroupingOptions
                let title = !selectedGroupingOptions.isEmpty ? localized("subscriptions.conversations") : ""
                assorter.registerSection(name: title, objects: queryItems)
            }

            assorter.registerModel(model: queryBase)
        }
    }

    var didUpdateIndexPaths: RealmAssorter<Subscription>.IndexPathsChangesEvent? {
        didSet {
            assorter?.didUpdateIndexPaths = self.didUpdateIndexPaths
        }
    }

    var updateVisibleCells: (() -> Void)?
}

// MARK: TableView

extension SubscriptionsViewModel {

    var hasLastMessage: Bool {
        return AuthSettingsManager.settings?.storeLastMessage ?? true
    }

    var numberOfSections: Int {
        return assorter?.numberOfSections ?? 0
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return assorter?.numberOfRowsInSection(section) ?? 0
    }

    func titleForHeaderInSection(_ section: Int) -> String {
        return assorter?.nameForSection(section) ?? "error"
    }

    func heightForHeaderIn(section: Int) -> Double {
        let numberOfRows = numberOfRowsInSection(section)
        let title = titleForHeaderInSection(section)

        return numberOfRows > 0 && !title.isEmpty ? 55 : 0
    }

    func absoluteIndexForIndexPath(_ indexPath: IndexPath) -> Int {
        return (0..<indexPath.section).reduce(0, { index, section in
            return index + numberOfRowsInSection(section)
        }) + indexPath.row
    }

    func indexPathForAbsoluteIndex(_ index: Int) -> IndexPath? {
        var count = 0
        let sections = (0..<numberOfSections).map({
            (0..<numberOfRowsInSection($0))
        }).enumerated()

        for (section, rows) in sections {
            if index > count + rows.count - 1 {
                count += rows.count
            } else {
                return IndexPath(row: index - count, section: section)
            }
        }

        return nil
    }

    func subscriptionForRowAt(indexPath: IndexPath) -> Subscription.UnmanagedType? {
        guard
            numberOfSections > indexPath.section,
            indexPath.section >= 0,
            numberOfRowsInSection(indexPath.section) > indexPath.row,
            indexPath.row >= 0
        else {
            return nil
        }

        return assorter?.objectForRowAtIndexPath(indexPath)
    }

}

private extension NSPredicate {
    var negation: NSPredicate {
        return NSCompoundPredicate(notPredicateWithSubpredicate: self)

    }
}
