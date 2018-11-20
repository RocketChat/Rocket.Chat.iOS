//
//  EnumExtensions.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 18.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

protocol LocalizableEnum {
    var localizedCase: String { get }
}

extension SubscriptionNotificationsStatus: LocalizableEnum {
    var localizedCase: String {
        return localized("subscription.notifications.status.\(rawValue)")
    }

}

extension SubscriptionNotificationsAudioValue: LocalizableEnum {
    var localizedCase: String {
        return localized("subscription.notifications.audio.value.\(rawValue)")
    }

}
