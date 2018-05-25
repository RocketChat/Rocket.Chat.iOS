//
//  NotificationManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Samar Sunkaria on 4/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class NotificationManagerSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        var uniqueConfiguration = Realm.Configuration.defaultConfiguration
        uniqueConfiguration.inMemoryIdentifier = NSUUID().uuidString
        Realm.Configuration.defaultConfiguration = uniqueConfiguration

        Realm.executeOnMainThread({ (realm) in
            realm.deleteAll()
        })
    }

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

    func testPostNotificationWhenNotifyingRoomIsOnScreen() {
        WindowManager.open(.chat)

        let rid = "UUUUUUUUUU"
        Realm.executeOnMainThread { (realm) in
            let object = Subscription()
            object.rid = rid
            realm.add(object, update: true)
        }

        var controller: ChatViewController?
        if let subscription = Realm.current?.objects(Subscription.self).filter("rid = '\(rid)'").first {
            if let nav = UIApplication.shared.windows.first?.rootViewController as? UINavigationController {
                if let chatController = nav.viewControllers.first as? ChatViewController {
                    chatController.subscription = subscription
                    controller = chatController
                }
            }
        }

        XCTAssertNotNil(controller)
        XCTAssertNotNil(controller?.subscription?.rid)

        var notification = self.notification
        notification.payload.rid = rid
        notification.post()

        XCTAssertNil(NotificationManager.shared.notification, "The notification should not post, and should not be stored")
        XCTAssertTrue(NotificationViewController.shared.notificationViewIsHidden, "The notification should not be visible")
    }

    func testPostNotificationWhenNotifyingRoomIsNotOnScreen() {
        WindowManager.open(.subscriptions)

        let rid = "UUUUUUUUUU"
        Realm.executeOnMainThread { (realm) in
            let object = Subscription()
            object.rid = rid
            realm.add(object, update: true)
        }

        if let subscription = Realm.current?.objects(Subscription.self).filter("rid = '\(rid)'").first {
            AppManager.open(room: subscription)
        }

        self.notification.post()

        XCTAssertNotNil(NotificationManager.shared.notification, "The notification should post, and should be stored")
        XCTAssertFalse(NotificationViewController.shared.notificationViewIsHidden, "The notification should be visible")
    }

    override func tearDown() {
        super.tearDown()
        NotificationManager.shared.notification = nil
        NotificationViewController.shared.timer?.fire()
        NotificationViewController.shared.timer = nil
        WindowManager.open(.auth(serverUrl: "", credentials: nil))
    }
}
