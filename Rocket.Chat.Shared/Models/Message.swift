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

/// An enum type represents the type of a message instance
///
/// - text: text message
/// - textAttachment: text message with an attachment
/// - image: image message
/// - audio: audio message
/// - video: video message
/// - url: url message
/// - roomNameChanged: a message that indicates a change of the name
/// - userAdded: a message that indicates an add of a user by admin
/// - userRemoved: a message that indicates a removal of a user by admin
/// - userJoined: a message that indicates a entrance of a user
/// - userLeft: a message that indicates a left of a user
/// - userMuted: a message that indicates muting of a user by admin
/// - userUnmuted: a message that indicates un-muting of a user by admin
/// - welcome: welcome message
/// - messageRemoved: a message that indicates a certain message has been removed
/// - subscriptionRoleAdded: subscriptionRoleAdded
/// - subscriptionRoleRemoved: subscriptionRoleRemoved
/// - roomArchived: a message that indicates the room have been archived
/// - roomUnarchived: a message that indicates the room have been un-archived
public enum MessageType: String {
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
}

/// A data structure represents a message instance
public class Message: BaseModel {
    public dynamic var subscription: Subscription!
    public dynamic var internalType: String = ""
    public dynamic var rid = ""
    public dynamic var createdAt: Date?
    public dynamic var updatedAt: Date?
    public dynamic var user: User?
    public dynamic var text = ""

    public dynamic var userBlocked: Bool = false

    public dynamic var pinned: Bool = false

    dynamic var alias = ""
    dynamic var avatar = ""

    dynamic var role = ""

    dynamic var temporary = false

    public var mentions = List<Mention>()
    public var attachments = List<Attachment>()
    public var urls = List<MessageURL>()

    public var type: MessageType {
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
