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

}
