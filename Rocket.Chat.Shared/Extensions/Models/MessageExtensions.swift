//
//  MessageExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 27/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

extension Message {

    func isSystemMessage() -> Bool {
        return !(
            type == .text ||
            type == .audio ||
            type == .image ||
            type == .video ||
            type == .textAttachment ||
            type == .url
        )
    }

    // swiftlint:disable function_body_length cyclomatic_complexity
    func textNormalized() -> String {
        let text = Emojione.transform(string: self.text)

        switch type {
            case .roomNameChanged:
                return String(
                    format: localized("chat.message.type.room_name_changed"),
                    text,
                    self.user?.displayName() ?? ""
                )

            case .userAdded:
                return String(
                    format: localized("chat.message.type.user_added_by"),
                    text,
                    self.user?.displayName() ?? ""
                )

            case .userRemoved:
                return String(
                    format: localized("chat.message.type.user_removed_by"),
                    text,
                    self.user?.displayName() ?? ""
                )

            case .userJoined:
                return localized("chat.message.type.user_joined")

            case .userLeft:
                return localized("chat.message.type.user_left")

            case .userMuted:
                return String(
                    format: localized("chat.message.type.user_muted"),
                    text,
                    self.user?.displayName() ?? ""
                )

            case .userUnmuted:
                return String(
                    format: localized("chat.message.type.user_unmuted"),
                    text,
                    self.user?.displayName() ?? ""
                )

            case .welcome:
                return String(
                    format: localized("chat.message.type.welcome"),
                    text
                )

            case .messageRemoved:
                return localized("chat.message.type.message_removed")

            case .subscriptionRoleAdded:
                return String(
                    format: localized("chat.message.type.subscription_role_added"),
                    text,
                    role,
                    self.user?.displayName() ?? ""
                )

            case .subscriptionRoleRemoved:
                return String(
                    format: localized("chat.message.type.subscription_role_removed"),
                    text,
                    role,
                    self.user?.displayName() ?? ""
                )

            case .roomArchived:
                return String(
                    format: localized("chat.message.type.room_archived"),
                    text
                )

            case .roomUnarchived:
                return String(
                    format: localized("chat.message.type.room_unarchived"),
                    text
                )

            default: break
        }

        return text
    }

}
