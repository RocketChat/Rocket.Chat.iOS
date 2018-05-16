//
//  Message.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

enum MessageType: String {
    case text
    case textAttachment
    case image
    case audio
    case video
    case url

    case roomNameChanged = "r"
    case userAdded = "au"
    case userRemoved = "ru"
    case userJoined = "uj"
    case userLeft = "ul"
    case userMuted = "user-muted"
    case userUnmuted = "user-unmuted"
    case welcome = "wm"
    case messageRemoved = "rm"
    case subscriptionRoleAdded = "subscription-role-added"
    case subscriptionRoleRemoved = "subscription-role-removed"
    case roomArchived = "room-archived"
    case roomUnarchived = "room-unarchived"

    case messagePinned = "message_pinned"

    var sequential: Bool {
        let sequential: [MessageType] = [.text, .textAttachment, .messageRemoved]

        return sequential.contains(self)
    }

    var actionable: Bool {
        let actionable: [MessageType] = [.text, .textAttachment, .image, .audio, .video, .url]

        return actionable.contains(self)
    }
}

final class Message: BaseModel {
    @objc dynamic var subscription: Subscription?
    @objc dynamic var internalType: String = ""
    @objc dynamic var rid = ""
    @objc dynamic var createdAt: Date?
    @objc dynamic var updatedAt: Date?
    @objc dynamic var user: User?
    @objc dynamic var text = ""

    @objc dynamic var userBlocked: Bool = false

    @objc dynamic var pinned: Bool = false

    @objc dynamic var alias = ""
    @objc dynamic var avatar: String?
    @objc dynamic var emoji: String?

    @objc dynamic var role = ""

    @objc dynamic var temporary = false

    @objc dynamic var groupable = true

    @objc dynamic var failed = false

    var starred = List<String>()
    var mentions = List<Mention>()
    var channels = List<Channel>()
    var attachments = List<Attachment>()
    var urls = List<MessageURL>()

    var reactions = List<MessageReaction>()

    var type: MessageType {
        if let type = MessageType(rawValue: internalType) {
            return type
        }

        if let attachment = attachments.first {
            return attachment.type
        }

        if let url = urls.first {
            if url.isValid() {
                return .url
            }
        }

        return  .text
    }

    // Internal
    @objc dynamic var markedForDeletion: Bool = false
}

extension Message {
    static func == (lhs: Message, rhs: Message) -> Bool {
        return
            lhs.identifier == rhs.identifier &&
            lhs.temporary == rhs.temporary &&
            lhs.failed == rhs.failed &&
            lhs.mentions.count == rhs.mentions.count &&
            lhs.channels.count == rhs.channels.count &&
            lhs.updatedAt?.timeIntervalSince1970 == rhs.updatedAt?.timeIntervalSince1970
    }
}
