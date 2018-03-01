//
//  Auth+CanBlockMessage.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension Auth {
    enum CanBlockMessageResult {
        case allowed
        case notActionable
        case myOwn
        case unknown
    }

    func canBlockMessage(_ message: Message) -> CanBlockMessageResult {
        guard let user = user else { return .unknown }

        if !message.type.actionable {
            return .notActionable
        }
        if message.user == user {
            return .myOwn
        }

        return .allowed
    }
}
