//
//  UnmanagedMessage.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 19/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit

struct UnmanagedMessageURL: Equatable {
    var url: String
    var title: String
    var subtitle: String
    var imageURL: String?
}

struct UnmanagedMention: Equatable {
    var userId: String?
    var realName: String?
    var username: String?
}

struct UnmanagedChannel: Equatable {
    var name: String
}

struct UnmanagedMessageReaction: Equatable {
    var emoji: String
    var usernames: [String]
}

extension Message: UnmanagedConvertible {
    typealias UnmanagedType = UnmanagedMessage

    var unmanaged: UnmanagedMessage? {
        return UnmanagedMessage(self)
    }
}

struct UnmanagedMessage: UnmanagedObject, Equatable {
    typealias Object = Message

    var identifier: String
    var rid: String
    var text: String
    var type: MessageType
    var internalType: String
    var attachments: [UnmanagedAttachment]
    var userIdentifier: String?
    var user: UnmanagedUser?
    var subscription: UnmanagedSubscription?
    var temporary: Bool
    var unread: Bool
    var failed: Bool
    var mentions: [UnmanagedMention]
    var channels: [UnmanagedChannel]
    var urls: [UnmanagedMessageURL]
    var reactions: [UnmanagedMessageReaction]
    var createdAt: Date
    var updatedAt: Date?
    var groupable: Bool
    var markedForDeletion: Bool
    var emoji: String?
    var role: String
    var avatar: String?
    var alias: String?
    var snippetName: String?
    var snippetId: String?

    var threadMessageId: String?
    var threadLastMessage: Date?
    var threadMessagesCount = 0
    var isThreadMainMessage: Bool { return threadMessagesCount > 0 }
    var isThreadReplyMessage: Bool { return !(threadMessageId?.isEmpty ?? true) }

    var discussionRid: String?
    var discussionLastMessage: Date?
    var discussionMessagesCount = 0

    var managedObject: Message? {
        return Message.find(withIdentifier: identifier)?.validated()
    }
}

extension UnmanagedMessage {
    static func == (lhs: UnmanagedMessage, rhs: UnmanagedMessage) -> Bool {
        return
            lhs.identifier == rhs.identifier &&
            lhs.type == rhs.type &&
            lhs.internalType == rhs.internalType &&
            lhs.temporary == rhs.temporary &&
            lhs.failed == rhs.failed &&
            lhs.markedForDeletion == rhs.markedForDeletion &&
            lhs.mentions == rhs.mentions &&
            lhs.channels == rhs.channels &&
            lhs.attachments.elementsEqual(rhs.attachments) &&
            lhs.urls == rhs.urls &&
            lhs.reactions == rhs.reactions &&
            lhs.threadMessageId == rhs.threadMessageId &&
            lhs.threadLastMessage == rhs.threadLastMessage &&
            lhs.threadMessagesCount == rhs.threadMessagesCount &&
            lhs.discussionRid == rhs.discussionRid &&
            lhs.discussionLastMessage == rhs.discussionLastMessage &&
            lhs.discussionMessagesCount == rhs.discussionMessagesCount &&
            lhs.updatedAt?.timeIntervalSince1970 == rhs.updatedAt?.timeIntervalSince1970
    }
}

extension UnmanagedMessage {

    // swiftlint:disable function_body_length
    init?(_ message: Message) {
        guard
            let messageIdentifier = message.identifier,
            let messageCreatedAt = message.createdAt
        else {
            #if DEBUG
            fatalError("message object is not complete")
            #endif

            return nil
        }

        identifier = messageIdentifier
        rid = message.rid
        text = message.text
        type = message.type
        internalType = message.internalType
        userIdentifier = message.userIdentifier
        user = message.user?.unmanaged
        subscription = message.subscription?.unmanaged
        temporary = message.temporary
        unread = message.unread
        failed = message.failed
        groupable = message.groupable
        markedForDeletion = message.markedForDeletion
        createdAt = messageCreatedAt
        updatedAt = message.updatedAt
        emoji = message.emoji
        role = message.role
        avatar = message.avatar
        alias = message.alias.isEmpty ? nil : message.alias
        snippetName = message.snippetName
        snippetId = message.snippetId

        threadMessageId = message.threadMessageId
        threadLastMessage = message.threadLastMessage
        threadMessagesCount = message.threadMessagesCount

        discussionRid = message.discussionRid
        discussionLastMessage = message.discussionLastMessage
        discussionMessagesCount = message.discussionMessagesCount

        mentions = message.mentions.compactMap {
            return UnmanagedMention(
                userId: $0.userId,
                realName: $0.realName,
                username: $0.username
            )
        }

        channels = message.channels.compactMap {
            guard let name = $0.name else { return nil }
            return UnmanagedChannel(name: name)
        }

        reactions = message.reactions.compactMap {
            guard let emoji = $0.emoji else { return nil }

            return UnmanagedMessageReaction(
                emoji: emoji,
                usernames: $0.usernames.compactMap({ $0 })
            )
        }

        urls = message.urls.compactMap {
            guard
                let title = $0.title,
                let subtitle = $0.textDescription,
                let url = $0.targetURL,
                $0.isValid()
            else {
                return nil
            }

            return UnmanagedMessageURL(
                url: url,
                title: title,
                subtitle: subtitle,
                imageURL: $0.imageURL
            )
        }

        attachments = message.attachments.compactMap {
            return UnmanagedAttachment($0)
        }
    }
}

extension UnmanagedMessage {

    internal var mainThreadTitle: String {
        if text.isEmpty, let attachment = attachments.first {
            let title = attachment.title

            if title.isEmpty, !attachment.fields.isEmpty {
                return attachment.fields.first?.title ?? title
            }

            return title
        }

        var messageText = MessageTextCacheManager.shared.message(for: self)?.string ?? text
        messageText = messageText.components(separatedBy: .newlines)
            .joined(separator: " ")
            .replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)

        return messageText
    }

    internal var mainThreadMessage: String? {
        guard
            isThreadReplyMessage,
            let threadMessageId = threadMessageId,
            !threadMessageId.isEmpty,
            let mainMessage = Message.find(withIdentifier: threadMessageId)?.unmanaged
        else {
            return nil
        }

        return mainMessage.mainThreadTitle
    }

    internal var threadReplyCompressedMessage: String {
        if self.text.isEmpty && !attachments.isEmpty {
            return attachments.first?.title ?? ""
        }

        var text = MessageTextCacheManager.shared.message(for: self)?.string ?? ""
        text = text.components(separatedBy: .newlines)
            .joined(separator: " ")
            .replacingOccurrences(of: "^\\s+", with: "", options: .regularExpression)

        return text
    }

}

extension UnmanagedMessage {

    /**
     This method will return if the reply button
     in a broadcast room needs to be displayed or
     not for the message. If the subscription is not
     a broadcast type, it'll return false.
     */
    func isBroadcastReplyAvailable() -> Bool {
        guard
            !temporary,
            !failed,
            !markedForDeletion,
            subscription?.roomBroadcast ?? false,
            !isSystemMessage(),
            let currentUser = AuthManager.currentUser(),
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
                self.user?.displayName ?? ""
            )

        case .userAdded:
            return String(
                format: localized("chat.message.type.user_added_by"),
                text,
                self.user?.displayName ?? ""
            )

        case .userRemoved:
            return String(
                format: localized("chat.message.type.user_removed_by"),
                text,
                self.user?.displayName ?? ""
            )

        case .userJoined:
            return localized("chat.message.type.user_joined")

        case .userLeft:
            return localized("chat.message.type.user_left")

        case .userMuted:
            return String(
                format: localized("chat.message.type.user_muted"),
                text,
                self.user?.displayName ?? ""
            )

        case .userUnmuted:
            return String(
                format: localized("chat.message.type.user_unmuted"),
                text,
                self.user?.displayName ?? ""
            )

        case .userJoinedConversation:
            return String(
                format: localized("chat.message.type.user_joined_conversation")
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
                self.user?.displayName ?? ""
            )

        case .subscriptionRoleRemoved:
            return String(
                format: localized("chat.message.type.subscription_role_removed"),
                text,
                role,
                self.user?.displayName ?? ""
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
            return ""

        case .messageSnippeted:
            return String(
                format: localized("chat.message.type.message_snippeted"),
                self.snippetName ?? ""
            )

        case .roomChangedPrivacy:
            return String(
                format: localized("chat.message.type.room_changed_privacy"),
                text,
                self.user?.displayName ?? ""
            )

        case .roomChangedTopic:
            return String(
                format: localized("chat.message.type.room_changed_topic"),
                text,
                self.user?.displayName ?? ""
            )

        case .roomChangedAnnouncement:
            return String(
                format: localized("chat.message.type.room_changed_announcement"),
                text,
                self.user?.displayName ?? ""
            )

        case .roomChangedDescription:
            return String(
                format: localized("chat.message.type.room_changed_description"),
                text,
                self.user?.displayName ?? ""
            )

        case .jitsiCallStarted:
            return String(
                format: localized("chat.message.type.video_call_started"),
                self.user?.displayName ?? ""
            )

        case .discussionCreated:
            return localized("chat.message.type.discussion_created")

        default:
            break
        }

        return text
    }

}

extension UnmanagedMessage: Differentiable {
    typealias DifferenceIdentifier = String
    var differenceIdentifier: String { return identifier }
}
