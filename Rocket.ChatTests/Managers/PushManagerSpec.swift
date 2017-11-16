//
//  PushManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/16/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

import UserNotifications

class PushManagerSpec: XCTestCase {
    func testSetupNotificationCenter() {
        PushManager.setupNotificationCenter()
        XCTAssert(UNUserNotificationCenter.current().delegate === PushManager.delegate)
    }
}

class PushNotificationSpec: XCTestCase {
    func testInit() {
        let raw = [
            "aps": [
                "alert": [
                    "title": "@user in #general",
                    "body": "Hello @you",
                    "sound": "chime.aiff"
                ],
                "badge": 5
            ],
            "ejson": "{\"host\":\"https://cardoso.rocket.chat/\",\"rid\":\"9euspXGgYsbEE5hi8\",\"sender\":{\"_id\":\"iBENea3v3cbD7RTry\",\"username\":\"cardoso\",\"name\":\"Matheus Cardoso\"},\"type\":\"c\",\"name\":\"general\"}",
            "messageFrom": "push"
        ] as [AnyHashable: Any]

        let notification = PushNotification(raw: raw)

        XCTAssertEqual(notification?.roomId, "9euspXGgYsbEE5hi8")
        XCTAssertEqual(notification?.host, "https://cardoso.rocket.chat/")
    }
}
