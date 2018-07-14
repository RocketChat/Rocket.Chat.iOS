//
//  NotificationPreferences.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 16.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class NotificationPreferences {
    let desktopNotifications: SubscriptionNotificationsStatus
    let disableNotifications: Bool
    let emailNotifications: SubscriptionNotificationsStatus
    let audioNotificationValue: SubscriptionNotificationsAudioValue
    let desktopNotificationDuration: Int
    let audioNotifications: SubscriptionNotificationsStatus
    let hideUnreadStatus: Bool
    let mobilePushNotifications: SubscriptionNotificationsStatus

    init(desktopNotifications: SubscriptionNotificationsStatus,
         disableNotifications: Bool,
         emailNotifications: SubscriptionNotificationsStatus,
         audioNotificationValue: SubscriptionNotificationsAudioValue,
         desktopNotificationDuration: Int,
         audioNotifications: SubscriptionNotificationsStatus,
         hideUnreadStatus: Bool,
         mobilePushNotifications: SubscriptionNotificationsStatus) {
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
