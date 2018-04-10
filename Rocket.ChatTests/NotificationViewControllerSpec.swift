//
//  NotificationViewControllerSpec.swift
//  Rocket.ChatTests
//
//  Created by Samar Sunkaria on 4/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class NotificationViewControllerSpec: XCTestCase {

    let notification = ChatNotification(
        sender: ChatNotification.Sender(name: "John Appleseed", username: "john.appleseed", id: "UUUUUUUUUUUU"),
        type: .channel("general"),
        title: "#general",
        body: "Hey!",
        rid: "UUUUUUUU"
    )

    func testNotificationIsVisible() {
        NotificationManager.post(notification: notification)
        XCTAssertFalse(NotificationViewController.shared.notificationViewIsHidden, "Notification view should be visible")
        NotificationViewController.shared.timer?.fire()
        XCTAssertTrue(NotificationViewController.shared.notificationViewIsHidden, "Notification view should be hidden")
    }
}
