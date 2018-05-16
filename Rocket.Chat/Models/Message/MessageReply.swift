//
//  MessageReply.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension Message {
    var quoteString: String? {
        guard
            let identifier = identifier,
            let subscription = subscription,
            let url = subscription.auth?.baseURL()
        else {
            return nil
        }

        let path: String

        switch subscription.type {
        case .channel:
            path = "channel"
        case .group:
            path = "group"
        case .directMessage:
            path = "direct"
        }

        return " [ ](\(url)/\(path)/\(subscription.name)?msg=\(identifier))"
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
