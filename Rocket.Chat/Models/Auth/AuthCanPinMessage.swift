//
//  AuthCanPinMessage.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 4/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension Auth {
    enum CanPinMessageResult {
        case allowed
        case notActionable
        case notAllowed
        case unknown
    }

    func canPinMessage(_ message: Message) -> CanPinMessageResult {
        guard
            let user = user,
            let settings = settings
        else {
            return .unknown
        }

        if !message.type.actionable {
            return .notActionable
        }

        if !settings.messageAllowPinning || !user.hasPermission(.pinMessage, realm: self.realm) {
            return .notAllowed
        }

        return .allowed
    }
}
