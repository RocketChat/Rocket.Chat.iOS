//
//  SubscriptionLastMessage.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 03/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension Subscription {

    func lastMessageText() -> String {
        guard
            let lastMessage = roomLastMessage,
            let userLastMessage = lastMessage.user
        else {
            return localized("subscriptions.list.no_message")
        }

        var text = MessageTextCacheManager.shared.message(for: lastMessage)?.string ?? lastMessage.text
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
