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

        XCTAssertEqual(model.numberOfSections(), 1)
        XCTAssertEqual(model.numberOfRows(in: 0), 2)
    }

    func testSettingsCellsWhenNotificationsDisabled() {
        model.enableModel.value.value = true

        XCTAssertEqual(model.numberOfSections(), 4)
        XCTAssertEqual(model.numberOfRows(in: 0), 2)
        XCTAssertEqual(model.numberOfRows(in: 1), 4)
        XCTAssertEqual(model.numberOfRows(in: 2), 1)
        XCTAssertEqual(model.numberOfRows(in: 3), 1)
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

        XCTAssertNotNil(model.saveButtonTitle)
        XCTAssertNotEqual(model.saveButtonTitle, "")

        XCTAssertNotNil(model.saveSuccessTitle)
        XCTAssertNotEqual(model.saveSuccessTitle, "")

        XCTAssertNotEqual(localized("alert.update_notifications_preferences_save_error.title"), "")

        XCTAssertNotEqual(localized("alert.update_notifications_preferences_save_error.message"), "")
    }

}
