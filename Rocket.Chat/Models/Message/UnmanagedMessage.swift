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

struct UnmanagedMessage: UnmanagedObject, Equatable {
    typealias Object = Message
    var identifier: String
    var managedObject: Message
    var text: String
    var attachments: [UnmanagedAttachment]
    var userIdentifier: String?
    var user: UnmanagedUser?
    var temporary: Bool
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
    var avatar: String?
}

extension UnmanagedMessage {
    static func == (lhs: UnmanagedMessage, rhs: UnmanagedMessage) -> Bool {
        return
            lhs.identifier == rhs.identifier &&
            lhs.temporary == rhs.temporary &&
            lhs.failed == rhs.failed &&
            lhs.mentions.count == rhs.mentions.count &&
            lhs.channels.count == rhs.channels.count &&
            lhs.updatedAt?.timeIntervalSince1970 == rhs.updatedAt?.timeIntervalSince1970
    }
}

extension UnmanagedMessage {
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

        managedObject = message
        identifier = messageIdentifier
        text = message.text
        userIdentifier = message.userIdentifier
        user = message.user?.unmanaged
        temporary = message.temporary
        failed = message.failed
        groupable = message.groupable
        markedForDeletion = message.markedForDeletion
        createdAt = messageCreatedAt
        updatedAt = message.updatedAt
        emoji = message.emoji
        avatar = message.avatar

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

extension UnmanagedMessage: Differentiable {
    typealias DifferenceIdentifier = String
    var differenceIdentifier: String { return identifier }
}
