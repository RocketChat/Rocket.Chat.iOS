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

    var sequential: Bool {
        let notSequential: [MessageType] = [.image, .video, .userJoined]

        return !notSequential.contains(self)
    }
}

class Message: BaseModel {
    dynamic var subscription: Subscription!
    dynamic var internalType: String = ""
    dynamic var rid = ""
    dynamic var createdAt: Date?
    dynamic var updatedAt: Date?
    dynamic var user: User?
    dynamic var text = ""

    dynamic var userBlocked: Bool = false

    dynamic var pinned: Bool = false

    dynamic var alias = ""
    dynamic var avatar = ""

    dynamic var role = ""

    dynamic var temporary = false

    var mentions = List<Mention>()
    var attachments = List<Attachment>()
    var urls = List<MessageURL>()

    var type: MessageType {
        if let attachment = attachments.first {
            return attachment.type
        }

        if let url = urls.first {
            if url.isValid() {
                return .url
            }
        }

        return MessageType(rawValue: internalType) ?? .text
    }
}
