//
//  SubscriptionsViewModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/20/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

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

    let realm: Realm?

    init(realm: Realm? = Realm.current) {
        self.realm = realm
    }

    deinit {
        assorter?.invalidate()
    }

    func buildSections() {
        if let realm = realm {
            assorter = RealmAssorter<Subscription>(realm: realm, results: subscriptions)
            assorter?.didUpdateIndexPaths = didUpdateIndexPaths
        }

        guard let assorter = assorter else {
            return
        }

        switch searchState {
        case .searching(let query):
            assorter.registerSection(name: localized("subscriptions.search_results")) {
                $0.filterBy(name: query)
            }

            API.current()?.client(SpotlightClient.self).search(query: query) { _ in }
        case .notSearching:
            if SubscriptionsSortingManager.selectedGroupingOptions.contains(.unread) {
                assorter.registerSection(name: localized("subscriptions.unreads")) {
                    $0.filter("alert == true")
                }
            }

            if SubscriptionsSortingManager.selectedGroupingOptions.contains(.favorites) {
                assorter.registerSection(name: localized("subscriptions.favorites")) {
                    $0.filter("favorite == true")
                }
            }

            if SubscriptionsSortingManager.selectedGroupingOptions.contains(.type) {
                assorter.registerSection(name: localized("subscriptions.channels")) {
                    $0.filter("privateType == 'c'")
                }
                assorter.registerSection(name: localized("subscriptions.groups")) {
                    $0.filter("privateType == 'p'")
                }
                assorter.registerSection(name: localized("subscriptions.direct_messages")) {
                    $0.filter("privateType == 'd'")
                }
            } else {
                let title = assorter.numberOfSections > 0 ? localized("subscriptions.conversations") : ""
                assorter.registerSection(name: title)
            }
        }
    }

    var didUpdateIndexPaths: IndexPathsChangesEvent?
    var didRebuildSections: (() -> Void)?
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

    func subscriptionForRowAt(indexPath: IndexPath) -> Subscription? {
        return assorter?.objectForRowAtIndexPath(indexPath)
    }

}
