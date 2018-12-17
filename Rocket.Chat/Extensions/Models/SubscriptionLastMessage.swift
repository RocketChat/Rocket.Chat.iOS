//
//  SubscriptionLastMessage.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 03/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension Subscription {

    /**
     This method returns the last message text for the Subscription. It should
     never be called directly on the interface.

     It will remove all the markdown tags, the initial breaking lines and will
     add some strings based on the context of the message.

     Examples:
     1. When the message is just an attachment: it'll return "Sent an attachment".
     2. When is a text message from other user, it'll return (username): message.

     - returns: the last message text for the Message object, after being processed.
     */
    static func lastMessageText(lastMessage: Message) -> String {
        guard
            let userLastMessage = lastMessage.user,
            let lastMessageUnmanaged = lastMessage.unmanaged
        else {
            return localized("subscriptions.list.no_message")
        }

        var text = MessageTextCacheManager.shared.message(for: lastMessageUnmanaged)?.string ?? lastMessage.text
        text = text.components(separatedBy: .newlines)
            .joined(separator: " ")
            .replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)

        let isFromCurrentUser = userLastMessage.identifier == AuthManager.currentUser()?.identifier
        let isOnlyAttachment = text.count == 0 && lastMessage.attachments.count > 0

        if isOnlyAttachment {
            text = " \(localized("subscriptions.list.sent_an_attachment"))"
        } else {
            if !isFromCurrentUser {
                text = ": \(text)"
            }
        }

        if isFromCurrentUser && isOnlyAttachment {
            text = "\(localized("subscriptions.list.you_initial"))\(text)"
        }

        if !isFromCurrentUser {
            text = "\(userLastMessage.displayName())\(text)"
        }

        return text
    }

}
