//
//  MessageReply.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension Message {
    var quoteString: String? {
        guard let permalink = subscription?.permalink(messageIdentifier: identifier) else {
            return nil
        }

        return " [ ](\(permalink))"
    }

    var replyString: String? {
        guard let quoteString = quoteString else { return nil }

        guard
            let subscription = subscription,
            subscription.type != .directMessage,
            let username = self.user?.username,
            username != AuthManager.currentUser()?.username
        else {
            return quoteString
        }

        return " @\(username)\(quoteString)"
    }
}
