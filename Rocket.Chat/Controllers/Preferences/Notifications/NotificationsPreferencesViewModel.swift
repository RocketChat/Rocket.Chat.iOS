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

    var subscription: Subscription? {
        didSet {
            guard let subscription = subscription else {
                return
            }

            enableModel.value.bind { [weak self] _ in
                self?.checkIfSaveButtonShouldBeEnabled(subscription: subscription)
            }

            counterModel.value.bind { [weak self] _ in
                self?.checkIfSaveButtonShouldBeEnabled(subscription: subscription)
            }

            desktopAlertsModel.value.bind { [weak self] _ in
                self?.checkIfSaveButtonShouldBeEnabled(subscription: subscription)
            }

            desktopAudioModel.value.bind { [weak self] _ in
                self?.checkIfSaveButtonShouldBeEnabled(subscription: subscription)
            }

            desktopSoundModel.value.bind { [weak self] _ in
                self?.checkIfSaveButtonShouldBeEnabled(subscription: subscription)
            }

            desktopDurationModel.value.bind { [weak self] _ in
                self?.checkIfSaveButtonShouldBeEnabled(subscription: subscription)
            }

            mobileAlertsModel.value.bind { [weak self] _ in
                self?.checkIfSaveButtonShouldBeEnabled(subscription: subscription)
            }

            mailAlertsModel.value.bind { [weak self] _ in
                self?.checkIfSaveButtonShouldBeEnabled(subscription: subscription)
            }
        }
    }

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
        return NotificationPreferences(
            desktopNotifications: desktopAlertsModel.value.value,
            disableNotifications: !enableModel.value.value,
            emailNotifications: mailAlertsModel.value.value,
            audioNotificationValue: desktopSoundModel.value.value,
            desktopNotificationDuration: desktopDurationModel.value.value,
            audioNotifications: desktopAudioModel.value.value,
            hideUnreadStatus: !counterModel.value.value,
            mobilePushNotifications: mobileAlertsModel.value.value
        )
    }

    internal var isSaveButtonEnabled = Dynamic(false)

    internal var channelName = "channel"

    internal let enableModel = NotificationsSwitchCell.SettingModel(
        value: Dynamic(false),
        type: .switch,
        title: localized("myaccount.settings.notifications.receive.title")
    )

    internal let counterModel = NotificationsSwitchCell.SettingModel(
        value: Dynamic(false),
        type: .switch,
        title: localized("myaccount.settings.notifications.show.title")
    )

    internal let desktopAlertsModel = NotificationsChooseCell.SettingModel(
        value: Dynamic(SubscriptionNotificationsStatus.default),
        options: SubscriptionNotificationsStatus.allCases,
        type: .list,
        title: localized("myaccount.settings.notifications.inapp.alerts"), pickerVisible: Dynamic(false)
    )

    internal let desktopAudioModel = NotificationsChooseCell.SettingModel(
        value: Dynamic(SubscriptionNotificationsStatus.default),
        options: SubscriptionNotificationsStatus.allCases,
        type: .list,
        title: localized("myaccount.settings.notifications.desktop.audio"), pickerVisible: Dynamic(false)
    )

    internal let desktopSoundModel = NotificationsChooseCell.SettingModel(
        value: Dynamic(SubscriptionNotificationsAudioValue.default),
        options: SubscriptionNotificationsAudioValue.allCases,
        type: .list,
        title: localized("myaccount.settings.notifications.desktop.sound"), pickerVisible: Dynamic(false)
    )

    internal let desktopDurationModel = NotificationsChooseCell.SettingModel(
        value: Dynamic(0),
        options: [0, 1, 2, 3, 4, 5],
        type: .list,
        title: localized("myaccount.settings.notifications.desktop.duration"), pickerVisible: Dynamic(false)
    )

    internal let mobileAlertsModel = NotificationsChooseCell.SettingModel(
        value: Dynamic(SubscriptionNotificationsStatus.default),
        options: SubscriptionNotificationsStatus.allCases,
        type: .list,
        title: localized("myaccount.settings.notifications.mobile.alerts"), pickerVisible: Dynamic(false)
    )

    internal let mailAlertsModel = NotificationsChooseCell.SettingModel(
        value: Dynamic(SubscriptionNotificationsStatus.default),
        options: SubscriptionNotificationsStatus.allCases,
        type: .list,
        title: localized("myaccount.settings.notifications.email.alerts"), pickerVisible: Dynamic(false)
    )

    private typealias TableSection = (header: String?, footer: String?, elements: [NotificationSettingModel])

    private var settingsCells: [TableSection] {
        let alwaysActiveSections: [TableSection] = [
            (header: nil, footer: String(format: localized("myaccount.settings.notifications.receive.footer"), channelName), [enableModel]),
            (header: nil, footer: localized("myaccount.settings.notifications.show.footer"), [counterModel])
        ]

        guard enableModel.value.value else {
            return alwaysActiveSections
        }

        let conditionallyActiveSections: [TableSection] = [
            (header: localized("myaccount.settings.notifications.inapp"), footer: localized("myaccount.settings.notifications.inapp.footer"), [desktopAlertsModel]),
            (header: localized("myaccount.settings.notifications.mobile"), footer: localized("myaccount.settings.notifications.mobile.footer"), [mobileAlertsModel]),
            (header: localized("myaccount.settings.notifications.desktop"), footer: nil, [desktopAudioModel, desktopSoundModel, desktopDurationModel]),
            (header: localized("myaccount.settings.notifications.mail"), footer: nil, [mailAlertsModel])
        ]

        return alwaysActiveSections + conditionallyActiveSections
    }

    internal func numberOfSections() -> Int {
        return settingsCells.count
    }

    internal func numberOfRows(in section: Int) -> Int {
        return settingsCells[section].elements.count
    }

    internal func titleForHeader(in section: Int) -> String? {
        return settingsCells[section].header
    }

    internal func titleForFooter(in section: Int) -> String? {
        return settingsCells[section].footer
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

    internal func checkIfSaveButtonShouldBeEnabled(subscription: Subscription) {
        isSaveButtonEnabled.value =
            enableModel.value.value == subscription.disableNotifications ||
            counterModel.value.value == subscription.hideUnreadStatus ||
            desktopAlertsModel.value.value != subscription.desktopNotifications ||
            desktopAudioModel.value.value != subscription.audioNotifications ||
            desktopSoundModel.value.value != subscription.audioNotificationValue ||
            desktopDurationModel.value.value != subscription.desktopNotificationDuration ||
            mobileAlertsModel.value.value != subscription.mobilePushNotifications ||
            mailAlertsModel.value.value != subscription.emailNotifications
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
