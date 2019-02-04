//
//  SubscriptionPermalink.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 20/12/2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension Subscription {
    func permalink(messageIdentifier: String? = nil) -> String? {
        guard let url = API.current(realm: realm)?.host else {
            return nil
        }

        let roomPath: String
        switch self.type {
        case .channel:
            roomPath = "channel"
        case .directMessage:
            roomPath = "direct"
        case .group:
            roomPath = "group"
        }

        var messagePostfix = ""
        if let identifier = messageIdentifier {
            messagePostfix = "?msg=\(identifier)"
        }

        return "\(url)/\(roomPath)/\(self.name)\(messagePostfix)"
    }

    func copyPermalink(messageIdentifier: String? = nil) {
        UIPasteboard.general.string = permalink(messageIdentifier: messageIdentifier)
    }
}
