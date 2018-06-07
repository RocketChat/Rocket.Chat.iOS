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
            id: "AAAAAAA",
            rid: "UUUUUUUU",
            name: "general",
            sender: ChatNotification.Payload.Sender(id: "UUUUUUUUUUUU", name: "John Appleseed", username: "john.appleseed"),
            internalType: "c"
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
        if notificationVC.isDeviceWithNotch {
            XCTAssert((UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow)?.alpha == 1, "Status bar should be visible")
        } else {
            XCTAssert((UIApplication.shared.value(forKey: "statusBarWindow") as? UIWindow)?.alpha == 0, "Status bar should not be visible")
        }
    }

    func testNotificationViewControllerIsVisible() {
        guard let notificaitonWindow = (UIApplication.shared.delegate as? AppDelegate)?.notificationWindow else {
            XCTFail("Notification window should be stored")
            return
        }
        XCTAssert(UIApplication.shared.windows.contains(notificaitonWindow), "Notification window should be added as a window to the application")
        XCTAssert(notificaitonWindow.rootViewController == NotificationViewController.shared, "The shared notification view controller should be the root view controller for the notification window")
    }

    func testNotificationWindowLevel() {
        let notificationVC = NotificationViewController.shared
        guard let notificaitonWindow = (UIApplication.shared.delegate as? AppDelegate)?.notificationWindow else {
            XCTFail("Notification window should be stored")
            return
        }

        if notificationVC.isDeviceWithNotch {
            XCTAssert(notificaitonWindow.windowLevel == UIWindowLevelStatusBar - 1, "Notification window level should be UIWindowLevelStatusBar - 1")
        } else {
            XCTAssert(notificaitonWindow.windowLevel == UIWindowLevelAlert, "Notification window level should be UIWindowLevelAlert")
        }
    }
}
