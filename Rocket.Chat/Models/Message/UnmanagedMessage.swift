//
//  UnmanagedMessage.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 19/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit

struct UnmanagedMessage: UnmanagedObject, Equatable {
    typealias Object = Message
    var identifier: String
    var managedObject: Message
    var text: String
    var attachments: [Attachment]
    var user: UnmanagedUser?
    var temporary: Bool
    var failed: Bool
    var mentions: [Mention]
    var channels: [Channel]
    var reactions: [MessageReaction]
    var createdAt: Date?
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
        guard let messageIdentifier = message.identifier else {
            return nil
        }

        managedObject = message
        identifier = messageIdentifier
        text = message.text
        user = message.user?.unmanaged
        temporary = message.temporary
        failed = message.failed
        groupable = message.groupable
        markedForDeletion = message.markedForDeletion
        mentions = message.mentions.map { $0 }
        channels = message.channels.map { $0 }
        reactions = message.reactions.map { $0 }
        createdAt = message.createdAt
        updatedAt = message.updatedAt
        emoji = message.emoji
        avatar = message.avatar

        attachments = message.attachments.compactMap({ attachment in
            if attachment.isFile && attachment.fullFileURL() != nil {
                return attachment
            }

            switch attachment.type {
            case .image where attachment.imageURL != nil:
                return attachment
            case .video where attachment.videoURL != nil:
                return attachment
            case .audio where attachment.audioURL != nil:
                return attachment
            case .textAttachment where attachment.fields.count > 0:
                return attachment
            default:
                break
            }

            return nil
        })
    }
}

extension UnmanagedMessage: Differentiable {
    typealias DifferenceIdentifier = String
    var differenceIdentifier: String { return identifier }
}
