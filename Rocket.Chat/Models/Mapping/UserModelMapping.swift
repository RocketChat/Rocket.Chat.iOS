//
//  UserModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension User: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = values["_id"].string
        }

        if let username = values["username"].string {
            self.username = username
        }

        if let name = values["name"].string {
            self.name = name
        }

        if let roles = values["roles"].array?.compactMap({ $0.string }) {
            self.roles.removeAll()
            self.roles.append(contentsOf: roles)
        }

        if let status = values["status"].string {
            self.status = UserStatus(rawValue: status) ?? .offline
        }

        if let utcOffset = values["utcOffset"].double {
            self.utcOffset = utcOffset
        }

        if let emailsRaw = values["emails"].array {
            let emails = emailsRaw.compactMap { emailRaw -> Email? in
                let email = Email(value: [
                    "email": emailRaw["address"].stringValue,
                    "verified": emailRaw["verified"].boolValue
                    ])

                guard !email.email.isEmpty else { return nil }

                return email
            }

            self.emails.removeAll()
            self.emails.append(contentsOf: emails)
        }

        if values["settings"].error == nil {
            settings = UserSettings()
            settings?.map(values["settings"], realm: realm)
        }
    }
}

extension UserSettings: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if values["preferences"].error == nil {
            preferences = UserPreferences()
            preferences?.map(values["preferences"], realm: realm)
        }
    }
}

extension UserPreferences: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        // from the docs
        roomNewNotification = values["newRoomNotification"].string
        messageNewNotification = values["newMessageNotification"].string
        useEmojis = values["useEmojis"].boolValue
        convertAsciiEmoji = values["convertAsciiEmoji"].boolValue
        saveMobileBandwidth = values["saveMobileBandwidth"].boolValue
        collapseMediaByDefault = values["collapseMediaByDefault"].boolValue
        muteFocusedConversations = values["muteFocusedConversations"].boolValue
        hideUsernames = values["hideUsernames"].boolValue
        hideFlexTab = values["hideFlexTab"].boolValue
        hideAvatars = values["hideAvatars"].boolValue
        sendOnEnter = values["sendOnEnter"].string
        autoImageLoad = values["autoImageLoad"].boolValue
        emailNotificationMode = values["emailNotificationMode"].string
        desktopNotificationDuration = values["desktopNotificationDuration"].intValue
        desktopNotifications = values["desktopNotifications"].string
        mobileNotifications = values["mobileNotifications"].string
        unreadAlert = values["unreadAlert"].boolValue
        notificationsSoundVolume = values["notificationsSoundVolume"].intValue
        roomCounterSidebar = values["roomCounterSidebar"].boolValue
        highlights = List<String>(values["highlights"].arrayValue.map { $0.stringValue })
        hideRoles = values["hideRoles"].boolValue
        enableAutoAway = values["enableAutoAway"].boolValue
        idleTimeLimit = values["idleTimeLimit"].intValue

        // from actual usage
        sidebarViewMode = values["sidebarViewMode"].string
        sidebarShowUnread = values["sidebarShowUnread"].boolValue
        sidebarHideAvatar = values["sidebarHideAvatar"].boolValue
        sidebarShowFavorites = values["sidebarShowFavorites"].boolValue
        sidebarSortBy = values["sidebarSortBy"].string

        mergeChannels = values["mergeChannels"].boolValue
    }
}
