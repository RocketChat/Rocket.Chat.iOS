//
//  NotificationsPreferencesViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 16.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class NotificationsPreferencesViewModelSpec: XCTestCase {

    let model = NotificationsPreferencesViewModel()

    func testSettingsCellsWhenNotificationsEnabled() {
        model.enableModel.value.value = false

        let cellModels = model.settingsCells

        XCTAssertEqual(cellModels.count, 1)

        let firstSection = cellModels[0]
        XCTAssertEqual(firstSection.elements.count, 2)
    }

    func testSettingsCellsWhenNotificationsDisabled() {
        model.enableModel.value.value = true

        let cellModels = model.settingsCells

        XCTAssertEqual(cellModels.count, 4)

        let firstSection = cellModels[0]
        XCTAssertEqual(firstSection.elements.count, 2)

        let secondSection = cellModels[1]
        XCTAssertEqual(secondSection.elements.count, 4)

        let thirdSection = cellModels[2]
        XCTAssertEqual(thirdSection.elements.count, 1)

        let fourthSection = cellModels[3]
        XCTAssertEqual(fourthSection.elements.count, 1)
    }

    func testCellModels() {
        model.enableModel.value.value = true
        model.counterModel.value.value = false
        model.desktopAlertsModel.value.value = SubscriptionNotificationsStatus.mentions.rawValue
        model.desktopAudioModel.value.value = SubscriptionNotificationsStatus.mentions.rawValue
        model.desktopSoundModel.value.value = SubscriptionNotificationsAudioValue.chelle.rawValue
        model.desktopDurationModel.value.value = String(2)
        model.mobileAlertsModel.value.value = SubscriptionNotificationsStatus.mentions.rawValue
        model.mailAlertsModel.value.value = SubscriptionNotificationsStatus.mentions.rawValue

        let notificationPreferences = model.notificationPreferences
        XCTAssertEqual(notificationPreferences.desktopNotifications, SubscriptionNotificationsStatus.mentions.rawValue)
        XCTAssertEqual(notificationPreferences.disableNotifications, false)
        XCTAssertEqual(notificationPreferences.emailNotifications, SubscriptionNotificationsStatus.mentions.rawValue)
        XCTAssertEqual(notificationPreferences.audioNotificationValue, SubscriptionNotificationsAudioValue.chelle.rawValue)
        XCTAssertEqual(notificationPreferences.desktopNotificationDuration, 2)
        XCTAssertEqual(notificationPreferences.audioNotifications, SubscriptionNotificationsStatus.mentions.rawValue)
        XCTAssertEqual(notificationPreferences.hideUnreadStatus, true)
        XCTAssertEqual(notificationPreferences.mobilePushNotifications, SubscriptionNotificationsStatus.mentions.rawValue)
    }

    func testStringsOverall() {
        XCTAssertNotNil(model.title)
        XCTAssertNotEqual(model.title, "")
    }

}
