//
//  Auth+CanEditMessage.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

extension Auth {
    enum CanEditMessageResult {
        case allowed
        case timeElapsed
        case differentUser
        case serverBlocked
        case notActionable
        case unknown
    }

    func canEditMessage(_ message: Message) -> CanEditMessageResult {
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

        if user.hasPermission(.editMessage, realm: self.realm) {
            return .allowed
        }

        func timeElapsed() -> Bool {
            if settings.messageAllowEditingBlockEditInMinutes < 1 {
                return false
            }

            return Date.serverDate.timeIntervalSince(createdAt)/60 > Double(settings.messageAllowDeletingBlockDeleteInMinutes)
        }

        if message.user != user { return .differentUser }
        if !settings.messageAllowEditing { return .serverBlocked }

        if timeElapsed() { return .timeElapsed }

        return .allowed
    }
}
