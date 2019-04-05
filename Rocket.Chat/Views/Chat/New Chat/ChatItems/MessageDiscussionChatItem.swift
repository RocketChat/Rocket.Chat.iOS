//
//  MessageDiscussionChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 03/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

final class MessageDiscussionChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return MessageDiscussionCell.identifier
    }

    override init(user: UnmanagedUser?, message: UnmanagedMessage?) {
        super.init(user: nil, message: message)
    }

    var buttonTitle: String {
        guard let message = message else { return "" }

        if message.discussionMessagesCount == 0 {
            return localized("discussion.no_messages")
        } else if message.discussionMessagesCount == 1 {
            return localized("discussion.1_message")
        }

        return String(format: localized("discussion.x_messages"), message.discussionMessagesCount.humanized())
    }

    var discussionTitle: NSAttributedString {
        guard let message = message else { return NSAttributedString(string: "") }

        let theme = ThemeManager.theme

        let attributedString = NSMutableAttributedString()

        let iconDiscussions = NSTextAttachment()
        iconDiscussions.image = UIImage(named: "Discussions")?.imageWithTint(theme.bodyText)

        let iconDiscussionsString = NSAttributedString(attachment: iconDiscussions)
        attributedString.append(iconDiscussionsString)

        attributedString.append(NSAttributedString(string: " \(message.text)"))

        return attributedString
    }

    var discussionLastMessageDate: String {
        if let lastMessageDate = message?.discussionLastMessage {
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

    func isContentEqual(to source: MessageDiscussionChatItem) -> Bool {
        guard let message = message, let sourceMessage = source.message else {
            return false
        }

        return message == sourceMessage
    }
}
