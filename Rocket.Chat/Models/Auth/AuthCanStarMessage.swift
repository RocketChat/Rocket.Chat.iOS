//
//  AuthCanStarMessage.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 4/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension Auth {
    enum CanStarMessageResult {
        case allowed
        case notActionable
        case notAllowed
        case unknown
    }

    func canStarMessage(_ message: Message) -> CanStarMessageResult {
        guard let settings = settings else {
            return .unknown
        }

        if !message.type.actionable {
            return .notActionable
        }

        if !settings.messageAllowStarring {
            return .notAllowed
        }

        return .allowed
    }
}
