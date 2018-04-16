//
//  NotificationPreferences.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 16.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

class NotificationPreferences {
    let desktopNotifications: String
    let disableNotifications: Bool
    let emailNotifications: String
    let audioNotificationValue: String
    let desktopNotificationDuration: Int
    let audioNotifications: String
    let hideUnreadStatus: Bool
    let mobilePushNotifications: String

    init(desktopNotifications: String, disableNotifications: Bool, emailNotifications: String, audioNotificationValue: String, desktopNotificationDuration: Int, audioNotifications: String, hideUnreadStatus: Bool, mobilePushNotifications: String) {
        self.desktopNotifications = desktopNotifications
        self.disableNotifications = disableNotifications
        self.emailNotifications = emailNotifications
        self.audioNotificationValue = audioNotificationValue
        self.desktopNotificationDuration = desktopNotificationDuration
        self.audioNotifications = audioNotifications
        self.hideUnreadStatus = hideUnreadStatus
        self.mobilePushNotifications = mobilePushNotifications
    }
}
