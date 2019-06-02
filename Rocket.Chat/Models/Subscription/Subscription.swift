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

enum SubscriptionNotificationsStatus: String, CaseIterable {
    case `default`
    case nothing
    case all
    case mentions
}

enum SubscriptionNotificationsAudioValue: String, CaseIterable {
    case none
    case `default`
    case beep
    case chelle
    case ding
    case droplet
    case highbell
    case seasons
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
    @objc dynamic var prid = ""

    // Name of the subscription
    @objc dynamic var name = ""

    // Full name of the user, in the case of
    // using the full user name setting
    // Setting: UI_Use_Real_Name
    @objc dynamic var fname = ""

    @objc dynamic var unread = 0
    @objc dynamic var userMentions = 0
    @objc dynamic var groupMentions = 0
    @objc dynamic var open = false
    @objc dynamic var alert = false
    @objc dynamic var favorite = false

    @objc dynamic var createdAt: Date?
    @objc dynamic var lastSeen: Date?

    @objc dynamic var usersCount = 0

    @objc dynamic var roomTopic: String?
    @objc dynamic var roomDescription: String?
    @objc dynamic var roomAnnouncement: String?
    @objc dynamic var roomReadOnly = false
    @objc dynamic var roomUpdatedAt: Date?
    @objc dynamic var roomLastMessage: Message?
    @objc dynamic var roomLastMessageText: String?
    @objc dynamic var roomLastMessageDate: Date?
    @objc dynamic var roomBroadcast = false

    let roomMuted = List<String>()

    @objc dynamic var roomOwnerId: String?
    @objc dynamic var otherUserId: String?

    @objc dynamic var disableNotifications = false
    @objc dynamic var hideUnreadStatus = false
    @objc dynamic var desktopNotificationDuration = 0

    @objc internal dynamic var privateDesktopNotifications = SubscriptionNotificationsStatus.default.rawValue
    @objc internal dynamic var privateEmailNotifications = SubscriptionNotificationsStatus.default.rawValue
    @objc internal dynamic var privateMobilePushNotifications = SubscriptionNotificationsStatus.default.rawValue
    @objc internal dynamic var privateAudioNotifications = SubscriptionNotificationsStatus.default.rawValue
    @objc internal dynamic var privateAudioNotificationsValue = SubscriptionNotificationsAudioValue.default.rawValue

    var desktopNotifications: SubscriptionNotificationsStatus {
        get { return SubscriptionNotificationsStatus(rawValue: privateDesktopNotifications) ?? .default }
        set { privateDesktopNotifications = newValue.rawValue }
    }
    var emailNotifications: SubscriptionNotificationsStatus {
        get { return SubscriptionNotificationsStatus(rawValue: privateEmailNotifications) ?? .default }
        set { privateEmailNotifications = newValue.rawValue }
    }
    var mobilePushNotifications: SubscriptionNotificationsStatus {
        get { return SubscriptionNotificationsStatus(rawValue: privateMobilePushNotifications) ?? .default }
        set { privateMobilePushNotifications = newValue.rawValue }
    }
    var audioNotifications: SubscriptionNotificationsStatus {
        get { return SubscriptionNotificationsStatus(rawValue: privateAudioNotifications) ?? .default }
        set { privateAudioNotifications = newValue.rawValue }
    }
    var audioNotificationValue: SubscriptionNotificationsAudioValue {
        get { return SubscriptionNotificationsAudioValue(rawValue: privateAudioNotificationsValue) ?? .default }
        set { privateAudioNotificationsValue = newValue.rawValue }
    }

    let usersRoles = List<RoomRoles>()

    // MARK: Internal
    @objc dynamic var privateOtherUserStatus: String?
    var otherUserStatus: UserStatus? {
        if let privateOtherUserStatus = privateOtherUserStatus {
            return UserStatus(rawValue: privateOtherUserStatus)
        } else {
            return nil
        }
    }

    var messages: Results<Message>? {
        return Realm.current?.objects(Message.self).filter("rid == '\(rid)'")
    }

    var isDiscussion: Bool {
        return !prid.isEmpty
    }

    static func find(rid: String, realm: Realm? = Realm.current) -> Subscription? {
        return realm?.objects(Subscription.self).filter("rid == '\(rid)'").first
    }

    static func find(name: String, realm: Realm? = Realm.current) -> Subscription? {
        return realm?.objects(Subscription.self).filter("name == '\(name)'").first
    }
}

final class RoomRoles: Object {
    @objc dynamic var user: User?
    var roles = List<String>()
}

// MARK: Avatar

extension Subscription {
    static func avatarURL(for name: String, auth: Auth? = nil) -> URL? {
        guard
            let auth = auth ?? AuthManager.isAuthenticated(),
            let baseURL = auth.baseURL(),
            let userId = auth.userId,
            let token = auth.token,
            let encodedName = name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        else {
            return nil
        }

        return URL(string: "\(baseURL)/avatar/%22\(encodedName)?format=jpeg&rc_uid=\(userId)&rc_token=\(token)")
    }
}

// MARK: Display Name

extension Subscription {
    func displayName() -> String {
        guard let settings = AuthSettingsManager.settings else {
            return name
        }

        if type != .directMessage {
            if !prid.isEmpty {
                return !fname.isEmpty ? fname : name
            }

            return settings.allowSpecialCharsOnRoomNames && !fname.isEmpty ? fname : name
        }

        return settings.useUserRealName && !fname.isEmpty ? fname : name
    }
}

// MARK: Unmanaged Object

extension Subscription: UnmanagedConvertible {
    typealias UnmanagedType = UnmanagedSubscription

    var unmanaged: UnmanagedSubscription? {
        return UnmanagedSubscription(self)
    }
}
