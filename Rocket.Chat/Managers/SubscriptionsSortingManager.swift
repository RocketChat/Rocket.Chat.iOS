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

    

}
