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
    var type: NotificationCellType { get }
}

final class NotificationsPreferencesViewModel {

    internal var title: String {
        return localized("myaccount.settings.notifications.title")
    }

    internal let enableModel = NotificationsSwitchCell.SettingModel(value: Dynamic(false),
                                                                                 type: .switch,
                                                                                 leftTitle: localized("myaccount.settings.notifications.mute.title"),
                                                                                 leftDescription: localized("myaccount.settings.notifications.mute.description"),
                                                                                 rightTitle: localized("myaccount.settings.notifications.receive.title"),
                                                                                 rightDescription: localized("myaccount.settings.notifications.receive.description"))

    internal let counterModel = NotificationsSwitchCell.SettingModel(value: Dynamic(false),
                                                                  type: .switch,
                                                                  leftTitle: localized("myaccount.settings.notifications.hide.title"),
                                                                  leftDescription: localized("myaccount.settings.notifications.hide.description"),
                                                                  rightTitle: localized("myaccount.settings.notifications.show.title"),
                                                                  rightDescription: localized("myaccount.settings.notifications.show.description"))

    internal let desktopAlertsModel = NotificationsChooseCell.SettingModel(value: Dynamic("Placeholder"),
                                                                    type: .list,
                                                                    title: localized("myaccount.settings.notifications.desktop.alerts"))

    internal let desktopAudioModel = NotificationsChooseCell.SettingModel(value: Dynamic("Placeholder"),
                                                                   type: .list,
                                                                   title: localized("myaccount.settings.notifications.desktop.audio"))

    internal let desktopSoundModel = NotificationsChooseCell.SettingModel(value: Dynamic("Placeholder"),
                                                                   type: .list,
                                                                   title: localized("myaccount.settings.notifications.desktop.sound"))

    internal let desktopDurationModel = NotificationsChooseCell.SettingModel(value: Dynamic("Placeholder"),
                                                                      type: .list,
                                                                      title: localized("myaccount.settings.notifications.desktop.duration"))

    internal let mobileAlertsModel = NotificationsChooseCell.SettingModel(value: Dynamic("Placeholder"),
                                                                         type: .list,
                                                                         title: localized("myaccount.settings.notifications.mobile.alerts"))

    internal let mailAlertsModel = NotificationsChooseCell.SettingModel(value: Dynamic("Placeholder"),
                                                                            type: .list,
                                                                            title: localized("myaccount.settings.notifications.email.alerts"))

    internal var settingsCells: [(title: String?, elements: [NotificationSettingModel])] {
        let firstSection: [(title: String?, elements: [NotificationSettingModel])] = [(title: nil, [enableModel, counterModel])]

        guard enableModel.value.value else {
            return firstSection
        }

        let secondSection: [(title: String?, elements: [NotificationSettingModel])] = [
            (title: localized("myaccount.settings.notifications.desktop"), [desktopAlertsModel, desktopAudioModel, desktopSoundModel, desktopDurationModel]),
            (title: localized("myaccount.settings.notifications.mobile"), [mobileAlertsModel]),
            (title: localized("myaccount.settings.notifications.mail"), [mailAlertsModel])
        ]

        return firstSection + secondSection
    }

}
