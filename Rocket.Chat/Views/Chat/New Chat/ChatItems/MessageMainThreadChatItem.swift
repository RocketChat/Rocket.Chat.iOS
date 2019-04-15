//
//  MessageMainThreadChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 03/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

final class MessageMainThreadChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return MessageMainThreadCell.identifier
    }

    override init(user: UnmanagedUser?, message: UnmanagedMessage?) {
        super.init(user: nil, message: message)
    }

    var buttonTitle: String {
        guard let message = message else { return "" }

        if message.threadMessagesCount == 0 {
            return localized("threads.no_replies")
        } else if message.threadMessagesCount == 1 {
            return localized("threads.1_reply")
        }

        return String(format: localized("threads.x_replies"), message.threadMessagesCount.humanized())
    }

    var threadLastMessageDate: String {
        if let lastMessageDate = message?.threadLastMessage {
            return formatLastMessageDate(lastMessageDate)
        }

        return ""
    }

    func formatLastMessageDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInYesterday(date) {
            return localized("subscriptions.list.date.yesterday")
        }

        if calendar.isDateInToday(date) {
            return RCDateFormatter.time(date)
        }

        return RCDateFormatter.date(date, dateStyle: .short)
    }

    var differenceIdentifier: String {
        return message?.identifier ?? ""
    }

    func isContentEqual(to source: MessageMainThreadChatItem) -> Bool {
        guard let message = message, let sourceMessage = source.message else {
            return false
        }

        return message == sourceMessage
    }
}
