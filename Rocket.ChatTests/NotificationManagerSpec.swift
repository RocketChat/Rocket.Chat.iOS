//
//  NotificationManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Samar Sunkaria on 4/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class NotificationManagerSpec: XCTestCase {

    let notification = ChatNotification(
        sender: ChatNotification.Sender(name: "John Appleseed", username: "john.appleseed", id: "UUUUUUUUUUUU"),
        type: .channel("general"),
        title: "#general",
        body: "Hey!",
        rid: "UUUUUUUU"
    )

    func testPostNotification() {
        NotificationManager.post(notification: notification)
        XCTAssertTrue(NotificationManager.shared.notification == notification, "Notification should be stored")
    }

    func testDidRespondToNotification() {
        NotificationManager.post(notification: notification)
        NotificationManager.shared.didRespondToNotification()
        XCTAssertNil(NotificationManager.shared.notification, "Stored notification should be nil")
    }

    func testMultipleNotifications() {
        var notification1 = notification
        notification1.title = "Notif1"
        notification1.post()
        XCTAssert(NotificationManager.shared.notification == notification1, "First notification should be stored")
        var notification2 = notification
        notification2.title = "Notif2"
        notification2.post()
        XCTAssert(NotificationManager.shared.notification == notification2, "Second notification should be stored")
        NotificationManager.shared.didRespondToNotification()
        XCTAssertNil(NotificationManager.shared.notification, "Stored notification should be nil")
    }
}
