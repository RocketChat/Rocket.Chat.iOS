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
        title: "#general",
        body: "Hey!",
        payload: ChatNotification.Payload(
            sender: ChatNotification.Sender(name: "John Appleseed", username: "john.appleseed", id: "UUUUUUUUUUUU"),
            type: .channel("general"),
            rid: "UUUUUUUU"
        )
    )

    func testNotificationIsVisible() {
        NotificationManager.post(notification: notification)
        XCTAssertFalse(NotificationViewController.shared.notificationViewIsHidden, "Notification view should be visible")
    }

    func testNotificationIsHidden() {
        NotificationManager.post(notification: notification)
        NotificationViewController.shared.timer?.fire()
        XCTAssertTrue(NotificationViewController.shared.notificationViewIsHidden, "Notification view should be hidden")
    }

    func testLayoutForHiddenNotificationView() {
        let notificationVC = NotificationViewController.shared
        notificationVC.notificationViewIsHidden = true
        XCTAssertFalse(notificationVC.visibleConstraint.isActive, "Visible constraint should not be active")
        XCTAssert(notificationVC.hiddenConstraint.isActive, "Hidden constraint should be active")
        XCTAssert((UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow)?.alpha == 1, "Status bar should be visible")
    }

    func testLayoutForVisibleNotificationView() {
        let notificationVC = NotificationViewController.shared
        notificationVC.notificationViewIsHidden = false
        notificationVC.notificationView.layoutIfNeeded()
        XCTAssert(notificationVC.visibleConstraint.isActive, "Visible constraint should be active")
        XCTAssertFalse(notificationVC.hiddenConstraint.isActive, "Hidden constraint should not be active")
        XCTAssert((UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow)?.alpha == 0, "Status bar should not be visible")
    }
}
