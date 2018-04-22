//
//  AuthCanBlockMessage.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension Auth {
    enum CanUnblockUserResult {
        case allowed
        case notActionable
        case myOwn
        case unknown
    }

    func canUnblockUser(_ message: Message) -> CanUnblockUserResult {
        guard let user = user else { return .unknown }

        if !message.userBlocked {
            return .notActionable
        }
        if message.user == user {
            return .myOwn
        }

        return .allowed
    }
}
