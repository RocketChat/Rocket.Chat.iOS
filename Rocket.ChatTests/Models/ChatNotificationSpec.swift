//
//  ChatNotificationSpec.swift
//  Rocket.ChatTests
//
//  Created by Samar Sunkaria on 4/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class ChatNotificationSpec: XCTestCase {
    func testChannelNotificationDecoding() {
        let notificationJson =
        """
        {
            "payload": {
                "sender": {
                    "name": "John Appleseed",
                    "username": "john.appleseed",
                    "_id": "UUUUUUUUUUUU"
                },
                "name": "general",
                "_id": "AAAAAAAAAAAA",
                "rid": "BBBBBBBBBBB",
            "type": "c"
            },
            "text": "Hello, world!",
            "title": "#general"
        }
        """

        guard let data = notificationJson.data(using: .utf8) else {
            XCTFail("Notification data found to be nil. Error in reading the string.")
            return
        }

        guard let chatNotification = try? JSONDecoder().decode(ChatNotification.self, from: data) else {
            XCTFail("The JSON could not be parsed.")
            return
        }

        let sender = ChatNotification.Sender(name: "John Appleseed", username: "john.appleseed", id: "UUUUUUUUUUUU")

        XCTAssertTrue(chatNotification.body == "Hello, world!")
        XCTAssertTrue(chatNotification.title == "#general")
        XCTAssertTrue(chatNotification.payload.rid == "BBBBBBBBBBB")
        XCTAssertTrue(chatNotification.payload.sender == sender)
        XCTAssertTrue(chatNotification.payload.type == .channel("general"))
    }

    func testDirectMessageNotificationDecoding() {
        let notificationJson =
        """
        {
            "payload" : {
                "sender" : {
                    "name" : "John Appleseed",
                    "username" : "john.appleseed",
                    "_id" : "UUUUUUUUUUUU"
                },
                "_id" : "AAAAAAAAAAAA",
                "rid" : "BBBBBBBBBBB",
                "type" : "d"
            },
            "text" : "Hey!",
            "title" : "@john.appleseed"
        }
        """

        guard let data = notificationJson.data(using: .utf8) else {
            XCTFail("Notification data found to be nil. Error in reading the string.")
            return
        }

        guard let chatNotification = try? JSONDecoder().decode(ChatNotification.self, from: data) else {
            XCTFail("The JSON could not be parsed.")
            return
        }

        let sender = ChatNotification.Sender(name: "John Appleseed", username: "john.appleseed", id: "UUUUUUUUUUUU")

        XCTAssertTrue(chatNotification.body == "Hey!", "notification body should be parsed correctly")
        XCTAssertTrue(chatNotification.title == "@john.appleseed", "notification title should be parsed correctly")
        XCTAssertTrue(chatNotification.payload.rid == "BBBBBBBBBBB", "notification rid should be parsed correctly")
        XCTAssertTrue(chatNotification.payload.sender == sender, "notification sender should be parsed correctly")
        XCTAssertTrue(chatNotification.payload.type == .direct(sender), "notification message type should be parsed correctly")
    }

    func testPostingNotification() {
        let notification = ChatNotification(
            title: "#general",
            body: "Hey!",
            payload: ChatNotification.Payload(
                sender: ChatNotification.Sender(name: "John Appleseed", username: "john.appleseed", id: "UUUUUUUUUUUU"),
                type: .channel("general"),
                rid: "UUUUUUUU"
            )
        )
        notification.post()
        XCTAssert(NotificationManager.shared.notification == notification, "notification should be stored in the notification manager")
    }
}
