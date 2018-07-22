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

    internal var saveSuccessTitle: String {
        return localized("alert.update_notifications_preferences_success.title")
    }

    internal var saveButtonTitle: String {
        return localized("myaccount.settings.notifications.save")
    }

    internal var notificationPreferences: NotificationPreferences {
        return NotificationPreferences(desktopNotifications: desktopAlertsModel.value.value,
                                       disableNotifications: !enableModel.value.value,
                                       emailNotifications: mailAlertsModel.value.value,
                                       audioNotificationValue: desktopSoundModel.value.value,
                                       desktopNotificationDuration: desktopDurationModel.value.value,
                                       audioNotifications: desktopAudioModel.value.value,
                                       hideUnreadStatus: !counterModel.value.value,
                                       mobilePushNotifications: mobileAlertsModel.value.value)
    }

    internal let enableModel = NotificationsSwitchCell.SettingModel(value: Dynamic(false),
                                                                    type: .switch,
                                                                    title: localized("myaccount.settings.notifications.mute.title"))

    internal let counterModel = NotificationsSwitchCell.SettingModel(value: Dynamic(false),
                                                                     type: .switch,
                                                                     title: localized("myaccount.settings.notifications.hide.title"))

    internal let desktopAlertsModel = NotificationsChooseCell.SettingModel(value: Dynamic(SubscriptionNotificationsStatus.default),
                                                                           options: SubscriptionNotificationsStatus.allCases,
                                                                           type: .list,
                                                                           title: localized("myaccount.settings.notifications.desktop.alerts"), pickerVisible: Dynamic(false))

    internal let desktopAudioModel = NotificationsChooseCell.SettingModel(value: Dynamic(SubscriptionNotificationsStatus.default),
                                                                          options: SubscriptionNotificationsStatus.allCases,
                                                                          type: .list,
                                                                          title: localized("myaccount.settings.notifications.desktop.audio"), pickerVisible: Dynamic(false))

    internal let desktopSoundModel = NotificationsChooseCell.SettingModel(value: Dynamic(SubscriptionNotificationsAudioValue.default),
                                                                          options: SubscriptionNotificationsAudioValue.allCases,
                                                                          type: .list,
                                                                          title: localized("myaccount.settings.notifications.desktop.sound"), pickerVisible: Dynamic(false))

    internal let desktopDurationModel = NotificationsChooseCell.SettingModel(value: Dynamic(0),
                                                                             options: [0, 1, 2, 3, 4, 5],
                                                                             type: .list,
                                                                             title: localized("myaccount.settings.notifications.desktop.duration"), pickerVisible: Dynamic(false))

    internal let mobileAlertsModel = NotificationsChooseCell.SettingModel(value: Dynamic(SubscriptionNotificationsStatus.default),
                                                                          options: SubscriptionNotificationsStatus.allCases,
                                                                          type: .list,
                                                                          title: localized("myaccount.settings.notifications.mobile.alerts"), pickerVisible: Dynamic(false))

    internal let mailAlertsModel = NotificationsChooseCell.SettingModel(value: Dynamic(SubscriptionNotificationsStatus.default),
                                                                        options: SubscriptionNotificationsStatus.allCases,
                                                                        type: .list,
                                                                        title: localized("myaccount.settings.notifications.email.alerts"), pickerVisible: Dynamic(false))

    private var settingsCells: [(title: String?, elements: [NotificationSettingModel])] {
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

    internal func numberOfSections() -> Int {
        return settingsCells.count
    }

    internal func numberOfRows(in section: Int) -> Int {
        return settingsCells[section].elements.count
    }

    internal func titleForHeader(in section: Int) -> String? {
        return settingsCells[section].title
    }

    internal func settingModel(for indexPath: IndexPath) -> NotificationSettingModel {
        return settingsCells[indexPath.section].elements[indexPath.row]
    }

    internal func openPicker(for indexPath: IndexPath) {
        for section in 0..<settingsCells.count {
            let elements = settingsCells[section].elements

            for row in 0..<elements.count {
                setPickerVisible(indexPath.section == section && indexPath.row == row, for: elements[row])
            }
        }
    }

    private func setPickerVisible(_ visible: Bool, for cellModel: NotificationSettingModel) {
        if let model = cellModel as? NotificationsChooseCell.SettingModel<SubscriptionNotificationsStatus> {
            model.pickerVisible.value = visible ? !model.pickerVisible.value : false
        } else if let model = cellModel as? NotificationsChooseCell.SettingModel<SubscriptionNotificationsAudioValue> {
            model.pickerVisible.value = visible ? !model.pickerVisible.value : false
        } else if let model = cellModel as? NotificationsChooseCell.SettingModel<Int> {
            model.pickerVisible.value = visible ? !model.pickerVisible.value : false
        }
    }
}
