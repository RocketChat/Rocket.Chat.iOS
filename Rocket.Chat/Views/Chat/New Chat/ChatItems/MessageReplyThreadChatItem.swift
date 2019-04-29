//
//  MessageReplyThreadChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 17/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

final class MessageReplyThreadChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return ThreadReplyCollapsedCell.identifier
    }

    override init(user: UnmanagedUser?, message: UnmanagedMessage?) {
        super.init(user: user, message: message)
    }

    internal var threadName: NSAttributedString {
        guard let message = message else { return NSAttributedString(string: "") }

        let theme = ThemeManager.theme

        let attributedString = NSMutableAttributedString()

        let iconDiscussions = NSTextAttachment()
        iconDiscussions.image = UIImage(named: "Threads")?.imageWithTint(theme.bodyText)

        let iconDiscussionsString = NSAttributedString(attachment: iconDiscussions)
        attributedString.append(iconDiscussionsString)
        attributedString.append(NSAttributedString(string: message.mainThreadMessage))
        return attributedString
    }

    var differenceIdentifier: String {
        return message?.identifier ?? ""
    }

    func isContentEqual(to source: MessageReplyThreadChatItem) -> Bool {
        guard let message = message, let sourceMessage = source.message else {
            return false
        }

        return message == sourceMessage
    }
}
