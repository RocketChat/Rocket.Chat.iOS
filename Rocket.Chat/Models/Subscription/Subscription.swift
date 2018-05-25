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

typealias RoomType = SubscriptionType

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
    @objc dynamic var roomLastMessageDate: Date?
    @objc dynamic var roomBroadcast = false

    let roomMuted = List<String>()

    @objc dynamic var roomOwnerId: String?
    @objc dynamic var otherUserId: String?

    let messages = LinkingObjects(fromType: Message.self, property: "subscription")

    let usersRoles = List<RoomRoles>()
}

final class RoomRoles: Object {
    @objc dynamic var user: User?
    var roles = List<String>()
}

// MARK: Failed Messages

extension Subscription {

    func avatarURL(auth: Auth? = nil) -> URL? {
        guard
            let auth = auth ?? AuthManager.isAuthenticated(),
            let baseURL = auth.baseURL(),
            let encodedName = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        else {
            return nil
        }

        return URL(string: "\(baseURL)/avatar/%22\(encodedName)?format=jpeg")
    }

    func setTemporaryMessagesFailed() {
        try? realm?.write {
            messages.filter("temporary = true").forEach {
                $0.temporary = false
                $0.failed = true
            }
        }
    }

}
