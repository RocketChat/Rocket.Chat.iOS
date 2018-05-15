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

extension PushNotification {
    static func testRaw() -> [AnyHashable: Any] {
        return  [
            "aps": [
                "alert": [
                    "title": "@user in #general",
                    "body": "Hello @you",
                    "sound": "chime.aiff"
                ],
                "badge": 5
            ],
            "ejson": "{\"host\":\"https://open.rocket.chat/\",\"rid\":\"9euspXGgYsbEE5hi8\",\"sender\":{\"_id\":\"iBENea3v3cbD7RTry\",\"username\":\"johnny.appleseed\",\"name\":\"Johnny Appleseed\"},\"type\":\"c\",\"name\":\"general\"}",
            "messageFrom": "push"
        ] as [AnyHashable: Any]
    }

    static func testRawInvalid() -> [AnyHashable: Any] {
        return  [
            "aps": [
                "alert": [
                    "title": "@user in #general",
                    "body": "Hello @you",
                    "sound": "chime.aiff"
                ],
                "badge": 5
            ],
            "messageFrom": "push"
            ] as [AnyHashable: Any]
    }
}

class PushManagerSpec: XCTestCase {
    func testSetupNotificationCenter() {
        PushManager.setupNotificationCenter()
        XCTAssert(UNUserNotificationCenter.current().delegate === PushManager.delegate)
    }

    func testHandleNotificationRaw() {
        DatabaseManager.removeServersKey()

        XCTAssertFalse(PushManager.handleNotification(raw: PushNotification.testRaw()))

        DatabaseManager.setupTestServers()

        XCTAssertFalse(PushManager.handleNotification(raw: PushNotification.testRawInvalid()))
        XCTAssert(PushManager.handleNotification(raw: PushNotification.testRaw(), reply: "test"))

        AppManager.changeSelectedServer(index: 1)
        XCTAssert(PushManager.handleNotification(raw: PushNotification.testRaw(), reply: "test"))
    }
}

class PushNotificationSpec: XCTestCase {
    func testInit() {
        let notification = PushNotification(raw: PushNotification.testRaw())

        XCTAssertEqual(notification?.roomId, "9euspXGgYsbEE5hi8")
        XCTAssertEqual(notification?.host, URL(string: "https://open.rocket.chat/"))
    }
}

class UserNotificationCenterDelegate: NSObject, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        PushManager.handleNotification(raw: response.notification.request.content.userInfo)
    }
}
