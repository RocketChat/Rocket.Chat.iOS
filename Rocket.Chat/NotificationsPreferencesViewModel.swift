//
//  NotificationsPreferencesViewModel.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 05.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

final class NotificationsPreferencesViewModel {

    enum CellType: String {
        // TODO: refactor to use parameters in case
        case `switch` = "NotificationsSwitchCell"
        case list = "NotificationsChooseCell"
    }

    struct SettingModel {
        let title: String
        let type: CellType

        init(title: String, type: CellType) {
            self.title = title
            self.type = type
        }
    }

    internal var title: String {
        return localized("myaccount.settings.notifications.title")
    }

    internal var settings: [(title: String?, elements: [SettingModel])] {
        return [
            (title: nil, [
                SettingModel(title: "Turn on", type: .switch),
                SettingModel(title: "Counter", type: .switch)
                ]),
            (title: "Desktop", [
                SettingModel(title: "Alerts", type: .list),
                SettingModel(title: "Audio", type: .list),
                SettingModel(title: "Sound", type: .list),
                SettingModel(title: "Duration", type: .list)
                ]),
            (title: "Mobile", [
                SettingModel(title: "Alerts", type: .list)
                ]),
            (title: "Email", [
                SettingModel(title: "Alerts", type: .list)
                ])
        ]
    }
}
