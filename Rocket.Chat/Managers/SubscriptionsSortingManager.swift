//
//  SubscriptionsSortingManager.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum SubscriptionsSortingOption {
    case activity
    case alphabetically
}

enum SubscriptionsGroupingOption {
    case unread
    case type
    case favorites
}

struct SubscriptionsSortingManager {

    // This String is the prefix of each kind of sorting &
    // grouping that will be persisted in UserDefaults.
    fileprivate static let kSortingKeyPrefix = "kSortingKey-%@"

    // Returns the generated key to the setting
    fileprivate static func key(for option: String) -> String {
        return "\(kSortingKeyPrefix)\(option)"
    }

    // Internal method to check the value of the key
    // on user defaults
    fileprivate static func isSelected(key: String) -> Bool {
        return UserDefaults.group.bool(forKey: key)
    }

    // Returns the selected sorting option
    static internal var selectedSortingOption: SubscriptionsSortingOption {
        return .activity
    }

    // Returns the selected grouping options
    static internal var selectedGroupingOptions: [SubscriptionsGroupingOption] {
        return [.unread, .type]
    }

}
