//
//  DateSeparatorChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 26/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct DateSeparatorChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return DateSeparatorCell.identifier
    }

    var date: Date

    var differenceIdentifier: String {
        return "\(date.timeIntervalSince1970)"
    }

    func isContentEqual(to source: DateSeparatorChatItem) -> Bool {
        return date == source.date
    }
}
