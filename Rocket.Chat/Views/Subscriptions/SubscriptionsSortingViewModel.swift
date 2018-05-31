//
//  SubscriptionsSortingViewModel.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 31/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum SubscriptionsSortingOption {
    case activity
    case alphabetically
}

enum SubscriptionGroupingOption {
    case unread
    case type
    case favorites
}

final class SubscriptionsSortingViewModel {

    internal let sortingOptions: [SubscriptionsSortingOption] = [.activity, .alphabetically]
    internal let groupingOptions: [SubscriptionGroupingOption] = [.type, .favorites, .unread]

    internal var viewHeight: CGFloat {
        return CGFloat(sortingOptions.count + sortingOptions.count) * ServerCell.cellHeight
    }

    internal var initialTableViewPosition: CGFloat {
        return (-viewHeight) - 80
    }

}
