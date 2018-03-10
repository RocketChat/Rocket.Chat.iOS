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
            NotificationsSwitchCell.SettingModel(value: "1", type: .switch, leftTitle: "q", leftDescription: "w", rightTitle: "e", rightDescription: "r"),
            NotificationsSwitchCell.SettingModel(value: "0", type: .switch, leftTitle: "t", leftDescription: "y", rightTitle: "u", rightDescription: "i"),
            ]),
        (title: "Desktop", [
            NotificationsChooseCell.SettingModel(value: "q", type: .list, title: "a"),
            NotificationsChooseCell.SettingModel(value: "w", type: .list, title: "b"),
            NotificationsChooseCell.SettingModel(value: "e", type: .list, title: "c"),
            NotificationsChooseCell.SettingModel(value: "r", type: .list, title: "d")
            ]),
        (title: "Mobile", [
            NotificationsChooseCell.SettingModel(value: "t", type: .list, title: "e")
            ]),
        (title: "Email", [
            NotificationsChooseCell.SettingModel(value: "y", type: .list, title: "f")
            ])
    ]
}
