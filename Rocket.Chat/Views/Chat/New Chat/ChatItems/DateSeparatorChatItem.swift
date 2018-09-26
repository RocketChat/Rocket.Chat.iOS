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

    var dateFormatted: String?
    var date: Date {
        didSet {
            let calendar = Calendar.current
            let components = calendar.dateComponents([.day, .month, .year], from: date)
            if let newDate = calendar.date(from: components) {
                dateFormatted = RCDateFormatter.date(newDate)
            }
        }
    }

    var differenceIdentifier: String {
        return "\(date.timeIntervalSince1970)"
    }

    func isContentEqual(to source: DateSeparatorChatItem) -> Bool {
        return date == source.date
    }
}
