//
//  SubscriptionsViewModel.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/20/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct SubscriptionsViewModel {
    var subscriptions: Results<Subscription>? {
        switch SubscriptionsSortingManager.selectedSortingOption {
        case .activity:
            return Subscription.all()?.sortedByLastMessageDate()
        case .alphabetically:
            return Subscription.all()?.sortedByName()
        }
    }

    enum SearchState {
        case searching(by: String, remotely: Bool)
        case notSearching
    }

    var searchState: SearchState = .notSearching

    var sortedSubscriptions: Results<Subscription>? {
        switch SubscriptionsSortingManager.selectedSortingOption {
        case .activity:
            return subscriptions?.sortedByLastMessageDate()
        case .alphabetically:
            return subscriptions?.sortedByName()
        }
    }

    // todo: try making these lazy
    var unreadSubscriptions: Results<Subscription>? {
        return subscriptions?.filter("alert == true")
    }

    var favoriteSubscriptions: Results<Subscription>? {
        return subscriptions?.filter("favorite == true")
    }

    var groupSubscriptions: Results<Subscription>? {
        return subscriptions?.filter("privateType == 'p'")
    }

    var channelSubscriptions: Results<Subscription>? {
        return subscriptions?.filter("privateType == 'c'")
    }

    var dmSubscriptions: Results<Subscription>? {
        return subscriptions?.filter("privateType == 'd'")
    }

    var searchedSubscriptions: Results<Subscription>? {
        if case let .searching(searchText, _) = searchState {
            return subscriptions?.filterBy(name: searchText)
        } else {
            return nil
        }
    }

    typealias SubscriptionsSection = (name: String, items: Results<Subscription>?)

    var tokens: [NotificationToken?] = []
    var sections: [SubscriptionsSection] = []

    mutating func buildSections() {
        self.tokens.forEach { $0?.invalidate() }

        var sections: [SubscriptionsSection] = []
        var tokens: [NotificationToken?] = []

        func addSection(_ section: SubscriptionsSection) {
            let index = sections.count
            tokens.append(section.items?.observe { [self, index] change in
                self.handleSectionUpdate(section: index, change: change)
            })

            sections.append(section)
        }

        switch searchState {
        case .searching:
                addSection((localized("subscriptions.search_results"), searchedSubscriptions))
        case .notSearching:
            if SubscriptionsSortingManager.selectedGroupingOptions.contains(.unread) {
                addSection((localized("subscriptions.unreads"), unreadSubscriptions))
            }

            if SubscriptionsSortingManager.selectedGroupingOptions.contains(.favorites) {
                addSection((localized("subscriptions.favorites"), favoriteSubscriptions))
            }

            if SubscriptionsSortingManager.selectedGroupingOptions.contains(.type) {
                addSection((localized("subscriptions.channels"), channelSubscriptions))
                addSection((localized("subscriptions.groups"), groupSubscriptions))
                addSection((localized("subscriptions.direct_messages"), dmSubscriptions))
            } else {
                addSection((localized("subscriptions.conversations"), subscriptions))
            }
        }

        self.sections = sections
        self.tokens = tokens
    }

    var sectionUpdated: ((_ deletions: [IndexPath], _ insertions: [IndexPath], _ modifications: [IndexPath]) -> Void)?

    private func handleSectionUpdate(section: Int, change: RealmCollectionChange<Results<Subscription>>) {
        switch change {
        case .update(_, let deletions, let insertions, let modifications):
            let toIndexPath = { (row: Int) in
                IndexPath(row: row, section: section)
            }

            let deletions = deletions.map(toIndexPath)
            let insertions = insertions.map(toIndexPath)
            let modifications = modifications.map(toIndexPath)

            sectionUpdated?(deletions, insertions, modifications)
        default:
            break
        }
    }
}

// MARK: TableView

extension SubscriptionsViewModel {
    var numberOfSections: Int {
        return sections.count
    }

    func numberOfRowsIn(section: Int) -> Int {
        guard sections.count > section else {
            return 0
        }

        return sections[section].items?.count ?? 0
    }

    func titleForHeaderIn(section: Int) -> String {
        guard sections.count > section else {
            return "error_out_of_bounds"
        }

        return sections[section].name
    }

    func heightForHeaderIn(section: Int) -> Double {
        return numberOfRowsIn(section: section) > 0 ? 55 : 0
    }

    func subscriptionForRowAt(indexPath: IndexPath) -> Subscription? {
        guard let items = sections[indexPath.section].items else {
            return nil
        }

        if items.count > indexPath.row {
            return items[indexPath.row]
        }

        return nil
    }
}
