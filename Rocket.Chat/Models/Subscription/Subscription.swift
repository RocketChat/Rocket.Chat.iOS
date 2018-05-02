//
//  Subscription.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/9/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

enum SubscriptionType: String, Equatable {
    case directMessage = "d"
    case channel = "c"
    case group = "p"
}

final class Subscription: BaseModel {
    @objc dynamic var auth: Auth?

    @objc internal dynamic var privateType = SubscriptionType.channel.rawValue
    var type: SubscriptionType {
        get { return SubscriptionType(rawValue: privateType) ?? SubscriptionType.group }
        set { privateType = newValue.rawValue }
    }

    @objc dynamic var rid = ""

    // Name of the subscription
    @objc dynamic var name = ""

    // Full name of the user, in the case of
    // using the full user name setting
    // Setting: UI_Use_Real_Name
    @objc dynamic var fname = ""

    @objc dynamic var unread = 0
    @objc dynamic var open = false
    @objc dynamic var alert = false
    @objc dynamic var favorite = false

    @objc dynamic var createdAt: Date?
    @objc dynamic var lastSeen: Date?

    @objc dynamic var roomTopic: String?
    @objc dynamic var roomDescription: String?
    @objc dynamic var roomReadOnly = false
    @objc dynamic var roomUpdatedAt: Date?
    @objc dynamic var roomLastMessage: Message?

    let roomMuted = RealmSwift.List<String>()

    @objc dynamic var roomOwnerId: String?
    @objc dynamic var otherUserId: String?

    let messages = LinkingObjects(fromType: Message.self, property: "subscription")
}

extension Subscription {

    func lastMessageText() -> String {
        guard
            let lastMessage = roomLastMessage,
            let userLastMessage = lastMessage.user
        else {
            return "No message"
        }

        var text = lastMessage.text

        let isFromCurrentUser = userLastMessage.identifier == AuthManager.currentUser()?.identifier
        let isOnlyAttachment = text.isEmpty && lastMessage.attachments.count > 0

        if isOnlyAttachment {
            text = " sent an attachment"
        } else {
            if !isFromCurrentUser {
                text = ": \(text)"
            }
        }

        if isFromCurrentUser && isOnlyAttachment {
            text = "You\(text)"
        }

        if !isFromCurrentUser {
            text = "\(userLastMessage.displayName())\(text)"
        }

        return text
    }

}

// MARK: Failed Messages

extension Subscription {

    func setTemporaryMessagesFailed() {
        try? realm?.write {
            messages.filter("temporary = true").forEach {
                $0.temporary = false
                $0.failed = true
            }
        }
    }

}
