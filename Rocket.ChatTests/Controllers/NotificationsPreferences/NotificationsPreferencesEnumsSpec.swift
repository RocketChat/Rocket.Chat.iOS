//
//  NotificationsPreferencesEnumsSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 17.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class NotificationsPreferencesEnumsSpec: XCTestCase {
    func testStatusEnum() {
        for status in SubscriptionNotificationsStatus.allCases {
            XCTAssertNotNil(status.localizedCase)
            XCTAssertNotEqual(status.localizedCase, "")
        }
    }

    func testAudioValueEnum() {
        for value in SubscriptionNotificationsAudioValue.allCases {
            XCTAssertNotNil(value.localizedCase)
            XCTAssertNotEqual(value.localizedCase, "")
        }
    }
}
