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

    func testPostNotification() {
        let notification = ChatNotification(
            sender: ChatNotification.Sender(name: "John Appleseed", username: "john.appleseed", id: "UUUUUUUUUUUU"),
            type: .channel("general"),
            title: "#general",
            body: "Hey!",
            rid: "UUUUUUUU"
        )
        NotificationManager.post(notification: notification)
        print("rood id: \(AppManager.currentRoomId)")
        XCTAssertTrue(NotificationManager.shared.notification == notification)
    }
}
