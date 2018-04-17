//
//  User.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/7/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

enum UserPresence: String {
    case online, away
}

enum UserStatus: String {
    case offline, online, busy, away
}

final class User: BaseModel {
    @objc dynamic var username: String?
    @objc dynamic var name: String?
    var emails = List<Email>()
    var roles = List<String>()
    @objc dynamic var settings: UserSettings?

    @objc internal dynamic var privateStatus = UserStatus.offline.rawValue
    var status: UserStatus {
        get { return UserStatus(rawValue: privateStatus) ?? UserStatus.offline }
        set { privateStatus = newValue.rawValue }
    }

    var utcOffset: Double?
}

final class UserSettings: Object {
    @objc dynamic var preferences: UserPreferences?
}

final class UserPreferences: Object {
    // from the docs
    @objc dynamic var roomNewNotification: String?
    @objc dynamic var messageNewNotification: String?
    @objc dynamic var useEmojis: Bool = false
    @objc dynamic var convertAsciiEmoji: Bool = false
    @objc dynamic var saveMobileBandwidth: Bool = false
    @objc dynamic var collapseMediaByDefault: Bool = false
    @objc dynamic var muteFocusedConversations: Bool = false
    @objc dynamic var hideUsernames: Bool = false
    @objc dynamic var hideFlexTab: Bool = false
    @objc dynamic var hideAvatars: Bool = false
    @objc dynamic var sendOnEnter: String?
    @objc dynamic var autoImageLoad: Bool = false
    @objc dynamic var emailNotificationMode: String?
    @objc dynamic var desktopNotificationDuration: Int = 0
    @objc dynamic var desktopNotifications: String?
    @objc dynamic var mobileNotifications: String?
    @objc dynamic var unreadAlert: Bool = false
    @objc dynamic var notificationsSoundVolume: Int = 0
    @objc dynamic var roomCounterSidebar: Bool = false
    var highlights: List<String> = List<String>()
    @objc dynamic var hideRoles: Bool = false
    @objc dynamic var enableAutoAway: Bool = false
    @objc dynamic var idleTimeLimit: Int = 0

    // from actual usage
    @objc dynamic var sidebarViewMode: String?
    @objc dynamic var sidebarSortBy: String?
    @objc dynamic var sidebarShowUnread: Bool = false
    @objc dynamic var sidebarHideAvatar: Bool = false
    @objc dynamic var sidebarShowFavorites: Bool = false

    @objc dynamic var mergeChannels: Bool = false
}
