//
//  NotificationPreferences.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 16.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

struct NotificationPreferences {
    let desktopNotifications: SubscriptionNotificationsStatus
    let disableNotifications: Bool
    let emailNotifications: SubscriptionNotificationsStatus
    let audioNotificationValue: SubscriptionNotificationsAudioValue
    let desktopNotificationDuration: Int
    let audioNotifications: SubscriptionNotificationsStatus
    let hideUnreadStatus: Bool
    let mobilePushNotifications: SubscriptionNotificationsStatus
}
