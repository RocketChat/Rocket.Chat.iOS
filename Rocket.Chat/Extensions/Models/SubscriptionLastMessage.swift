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
                return "No message"
        }

        var text = lastMessage.text

        let isFromCurrentUser = userLastMessage.identifier == AuthManager.currentUser()?.identifier
        let isOnlyAttachment = text.isEmpty && lastMessage.attachments.count > 0

        if isOnlyAttachment {
            text = " sent an attachment"
        } else {
            if !isFromCurrentUser {
                text = ": \(text)"
            }
        }

        if isFromCurrentUser && isOnlyAttachment {
            text = "You\(text)"
        }

        if !isFromCurrentUser {
            text = "\(userLastMessage.displayName())\(text)"
        }

        return text
    }

}
