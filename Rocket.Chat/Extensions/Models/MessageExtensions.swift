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

    func textNormalized() -> String {
        let text = Emojione.transform(string: self.text)

        switch type {
            case .roomNameChanged:
                return String(
                    format: localizedString("chat.message.type.room_name_changed"),
                    text,
                    self.user?.username ?? ""
                )

            case .userAdded:
                return String(
                    format: localizedString("chat.message.type.user_added_by"),
                    text,
                    self.user?.username ?? ""
                )

            case .userRemoved:
                return String(
                    format: localizedString("chat.message.type.user_removed_by"),
                    text,
                    self.user?.username ?? ""
                )

            case .userJoined:
                return localizedString("chat.message.type.user_joined")

            case .userLeft:
                return localizedString("chat.message.type.user_left")

            case .userMuted:
                return String(
                    format: localizedString("chat.message.type.user_muted"),
                    text,
                    self.user?.username ?? ""
                )

            case .userUnmuted:
                return String(
                    format: localizedString("chat.message.type.user_unmuted"),
                    text,
                    self.user?.username ?? ""
                )

            case .welcome:
                return String(
                    format: localizedString("chat.message.type.welcome"),
                    text
                )

            case .messageRemoved:
                return localizedString("chat.message.type.message_removed")

            case .subscriptionRoleAdded:
                return String(
                    format: localizedString("chat.message.type.subscription_role_added"),
                    text,
                    role,
                    self.user?.username ?? ""
                )

            case .subscriptionRoleRemoved:
                return String(
                    format: localizedString("chat.message.type.subscription_role_removed"),
                    text,
                    role,
                    self.user?.username ?? ""
                )

            case .roomArchived:
                return String(
                    format: localizedString("chat.message.type.room_archived"),
                    text
                )

            case .roomUnarchived:
                return String(
                    format: localizedString("chat.message.type.room_unarchived"),
                    text
                )

            default: break
        }

        return text
    }

}
