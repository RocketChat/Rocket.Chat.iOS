//
//  SubscriptionLastMessage.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 03/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension Subscription {

    func lastMessageText() -> NSAttributedString {
        guard
            let lastMessage = roomLastMessage,
            let userLastMessage = lastMessage.user
        else {
            return NSAttributedString(string: "No message")
        }

        var text: NSMutableAttributedString = MessageTextCacheManager.shared.messageSimplified(for: lastMessage) ?? NSMutableAttributedString(string: lastMessage.text)

        let isFromCurrentUser = userLastMessage.identifier == AuthManager.currentUser()?.identifier
        let isOnlyAttachment = text.length == 0 && lastMessage.attachments.count > 0

        if isOnlyAttachment {
            text = NSMutableAttributedString(string: " sent an attachment")
        } else {
            if !isFromCurrentUser {
                let attributedString = NSMutableAttributedString(string: ": ")
                attributedString.append(text)

                text = attributedString
            }
        }

        if isFromCurrentUser && isOnlyAttachment {
            let attributedString = NSMutableAttributedString(string: "You")
            attributedString.append(text)

            text = attributedString
        }

        if !isFromCurrentUser {
            let attributedString = NSMutableAttributedString(string: "\(userLastMessage.displayName())")
            attributedString.append(text)

            text = attributedString
        }

        text.setFontColor(MessageTextFontAttributes.systemFontColor)
        return text
    }

}
