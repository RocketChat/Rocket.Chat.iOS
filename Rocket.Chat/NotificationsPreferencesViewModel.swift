//
//  NotificationsPreferencesViewModel.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum NotificationCellType: String {
    case `switch` = "NotificationsSwitchCell"
    case list = "NotificationsChooseCell"
}

protocol NotificationSettingModel {
    var value: String { get }
    var type: NotificationCellType { get }
}

final class NotificationsPreferencesViewModel {

    internal var title: String {
        return localized("myaccount.settings.notifications.title")
    }

    internal let settings: [(title: String?, elements: [NotificationSettingModel])] = [
        (title: nil, [
            NotificationsSwitchCell.SettingModel(value: "1",
                                                 type: .switch,
                                                 leftTitle: localized("myaccount.settings.notifications.mute.title"),
                                                 leftDescription: localized("myaccount.settings.notifications.mute.description"),
                                                 rightTitle: localized("myaccount.settings.notifications.receive.title"),
                                                 rightDescription: localized("myaccount.settings.notifications.receive.description")),
            NotificationsSwitchCell.SettingModel(value: "0",
                                                 type: .switch,
                                                 leftTitle: localized("myaccount.settings.notifications.hide.title"),
                                                 leftDescription: localized("myaccount.settings.notifications.hide.description"),
                                                 rightTitle: localized("myaccount.settings.notifications.show.title"),
                                                 rightDescription: localized("myaccount.settings.notifications.show.description"))
            ]),
        (title: localized("myaccount.settings.notifications.desktop"), [
            NotificationsChooseCell.SettingModel(value: "Placeholder",
                                                 type: .list,
                                                 title: localized("myaccount.settings.notifications.desktop.alerts")),
            NotificationsChooseCell.SettingModel(value: "Placeholder",
                                                 type: .list,
                                                 title: localized("myaccount.settings.notifications.desktop.audio")),
            NotificationsChooseCell.SettingModel(value: "Placeholder",
                                                 type: .list,
                                                 title: localized("myaccount.settings.notifications.desktop.sound")),
            NotificationsChooseCell.SettingModel(value: "Placeholder",
                                                 type: .list,
                                                 title: localized("myaccount.settings.notifications.desktop.duration"))
            ]),
        (title: localized("myaccount.settings.notifications.mobile"), [
            NotificationsChooseCell.SettingModel(value: "Placeholder",
                                                 type: .list,
                                                 title: localized("myaccount.settings.notifications.mobile.alerts"))
            ]),
        (title: localized("myaccount.settings.notifications.mail"), [
            NotificationsChooseCell.SettingModel(value: "Placeholder",
                                                 type: .list,
                                                 title: localized("myaccount.settings.notifications.email.alerts"))
            ])
    ]
}
