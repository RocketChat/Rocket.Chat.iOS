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

class Subscription: BaseModel {
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

    let roomMuted = RealmSwift.List<String>()

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

    let messages = LinkingObjects(fromType: Message.self, property: "subscription")
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
