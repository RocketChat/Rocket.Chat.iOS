//
//  SubscriptionsSortingViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 31/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class SubscriptionsSortingViewModel {

    internal let sortingOptions: [SubscriptionsSortingOption] = [.activity, .alphabetically]
    internal let groupingOptions: [SubscriptionsGroupingOption] = [.type, .favorites, .unread]

    internal var listSeparatorHeight: CGFloat = 10.0
    internal var viewHeight: CGFloat {
        return CGFloat(sortingOptions.count + groupingOptions.count) * SubscriptionSortingCell.cellHeight + listSeparatorHeight
    }

    internal var initialTableViewPosition: CGFloat {
        return (-viewHeight) - 80
    }

    internal let numberOfSections = 2

    internal func numberOfRows(section: Int) -> Int {
        if section == 0 {
            return sortingOptions.count
        }

        return groupingOptions.count
    }

    // MARK: Titles

    internal var sortingTitleDescription: String {
        if SubscriptionsSortingManager.selectedSortingOption == .alphabetically {
            return localized("subscriptions.sorting.title.alphabetical")
        }

        return localized("subscriptions.sorting.title.activity")
    }

    internal func title(for sortingOption: SubscriptionsSortingOption) -> String {
        switch sortingOption {
        case .activity: return localized("subscriptions.sorting.activity")
        case .alphabetically: return localized("subscriptions.sorting.alphabetical")
        }
    }

    internal func title(for groupingOption: SubscriptionsGroupingOption) -> String {
        switch groupingOption {
        case .favorites: return localized("subscriptions.grouping.favorites")
        case .type: return localized("subscriptions.grouping.type")
        case .unread: return localized("subscriptions.grouping.unread_top")
        }
    }

    internal func title(for indexPath: IndexPath) -> String {
        if indexPath.section == 0 {
            return title(for: sortingOptions[indexPath.row])
        }

        return title(for: groupingOptions[indexPath.row])
    }

    // MARK: Images

    internal func image(for sortingOption: SubscriptionsSortingOption) -> UIImage? {
        switch sortingOption {
        case .activity: return UIImage(named: "Sort Activity")
        case .alphabetically: return UIImage(named: "Sort Alphabetically")
        }
    }

    internal func image(for groupingOption: SubscriptionsGroupingOption) -> UIImage? {
        switch groupingOption {
        case .favorites: return UIImage(named: "Group Favorites")
        case .type: return UIImage(named: "Group Type")
        case .unread: return UIImage(named: "Group Unread")
        }
    }

    internal func image(for indexPath: IndexPath) -> UIImage? {
        if indexPath.section == 0 {
            return image(for: sortingOptions[indexPath.row])
        }

        return image(for: groupingOptions[indexPath.row])
    }

    // MARK: Selection

    internal func isSelected(indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            let option = sortingOptions[indexPath.row]
            return option == SubscriptionsSortingManager.selectedSortingOption
        }

        let option = groupingOptions[indexPath.row]
        return SubscriptionsSortingManager.selectedGroupingOptions.contains(option)
    }

    internal func select(indexPath: IndexPath) {
        if indexPath.section == 0 {
            SubscriptionsSortingManager.select(option: sortingOptions[indexPath.row])
        }

        if indexPath.section == 1 {
            SubscriptionsSortingManager.toggle(option: groupingOptions[indexPath.row].rawValue)
        }
    }

}
