//
//  Auth+CanDeleteMessage.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension Auth {
    enum CanDeleteMessageResult {
        case allowed
        case timeElapsed
        case differentUser
        case serverBlocked
        case notActionable
        case unknown
    }

    func canDeleteMessage(_ message: Message) -> CanDeleteMessageResult {
        guard
            let createdAt = message.createdAt,
            let user = user,
            let settings = settings
            else {
                return .unknown
        }

        if !message.type.actionable {
            return .notActionable
        }

        if user.hasPermission(.forceDeleteMessage, realm: self.realm) {
            return .allowed
        }

        func timeElapsed() -> Bool {
            if settings.messageAllowDeletingBlockDeleteInMinutes < 1 {
                return false
            }

            return Date.serverDate.timeIntervalSince(createdAt)/60 > Double(settings.messageAllowDeletingBlockDeleteInMinutes)
        }

        if user.hasPermission(.deleteMessage, realm: self.realm) {
            return timeElapsed() ? .timeElapsed : .allowed
        }

        if message.user != user { return .differentUser }
        if !settings.messageAllowDeleting { return .serverBlocked }

        if timeElapsed() { return .timeElapsed }

        return .allowed
    }
}
