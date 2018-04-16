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
        model.desktopAlertsModel.value.value = .mentions
        model.desktopAudioModel.value.value = .mentions
        model.desktopSoundModel.value.value = .chelle
        model.desktopDurationModel.value.value = 2
        model.mobileAlertsModel.value.value = .mentions
        model.mailAlertsModel.value.value = .mentions

        let notificationPreferences = model.notificationPreferences
        XCTAssertEqual(notificationPreferences.desktopNotifications, .mentions)
        XCTAssertEqual(notificationPreferences.disableNotifications, false)
        XCTAssertEqual(notificationPreferences.emailNotifications, .mentions)
        XCTAssertEqual(notificationPreferences.audioNotificationValue, .chelle)
        XCTAssertEqual(notificationPreferences.desktopNotificationDuration, 2)
        XCTAssertEqual(notificationPreferences.audioNotifications, .mentions)
        XCTAssertEqual(notificationPreferences.hideUnreadStatus, true)
        XCTAssertEqual(notificationPreferences.mobilePushNotifications, .mentions)
    }

    func testStringsOverall() {
        XCTAssertNotNil(model.title)
        XCTAssertNotEqual(model.title, "")
    }

}
