//
//  MessageExtensions.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 27/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RealmSwift

extension Message {

    /**
        This method will return if the reply button
        in a broadcast room needs to be displayed or
        not for the message. If the subscription is not
        a broadcast type, it'll return false.
     */
    func isBroadcastReplyAvailable(realm: Realm? = Realm.current) -> Bool {
        guard
            !temporary,
            !failed,
            !markedForDeletion,
            subscription?.roomBroadcast ?? false,
            !isSystemMessage(),
            let currentUser = AuthManager.currentUser(realm: realm),
            currentUser.identifier != user?.identifier
        else {
            return false
        }

        return true
    }

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

        case .messagePinned:
            return localized("chat.message.type.message_pinned")

        default:
            break
        }

        return text
    }

}

// MARK: Accessibility

extension Message {
    override var accessibilityLabel: String? {
        get {
            guard
                let createdAt = createdAt,
                let user = user,
                let format = VOLocalizedString("message.label")
            else {
                return nil
            }

            let formatter = DateFormatter()
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            formatter.doesRelativeDateFormatting = true
            let date = formatter.string(from: createdAt)

            return String(format: format, user.displayName(), date)
        }
        set { }
    }

    override var accessibilityValue: String? {
        get { return textNormalized() }
        set { }
    }

    override var accessibilityHint: String? {
        get {
            guard let format = VOLocalizedString("message.hint") else { return nil }

            return String(format: format, self.reactions.reduce("") {
                return $0 + """
                \(Emojione.transform(string: $1.emoji ?? ""))
                \($1.usernames.count): \($1.usernames.joined(separator: ", "))

                """
            })
        }

        set { }
    }
}
