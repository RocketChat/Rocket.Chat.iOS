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

    override func setUp() {
        super.setUp()
        NotificationManager.post(notification: notification)
    }

    func testPostNotification() {
        XCTAssertTrue(NotificationManager.shared.notification == notification, "Notification should be stored")
    }

    func testDidRespondToNotification() {
        NotificationManager.shared.didRespondToNotification()
        XCTAssertNil(NotificationManager.shared.notification, "Notification should be nil")
    }
}
