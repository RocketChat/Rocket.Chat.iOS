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

        let sender = ChatNotification.Payload.Sender(id: "UUUUUUUUUUUU", name: "John Appleseed", username: "john.appleseed")

        XCTAssertTrue(chatNotification.body == "Hello, world!", "notification body should be parsed correctly")
        XCTAssertTrue(chatNotification.title == "#general", "notification title should be parsed correctly")
        XCTAssertTrue(chatNotification.payload.rid == "BBBBBBBBBBB", "notification rid should be parsed correctly")
        XCTAssertTrue(chatNotification.payload.sender == sender, "notification sender should be parsed correctly")
        XCTAssertTrue(chatNotification.payload.type == .channel, "notification message type should be parsed correctly")
        XCTAssertTrue(chatNotification.payload.name == "general", "notification room name should not be nil")
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

        let sender = ChatNotification.Payload.Sender(id: "UUUUUUUUUUUU", name: "John Appleseed", username: "john.appleseed")

        XCTAssertTrue(chatNotification.body == "Hey!", "notification body should be parsed correctly")
        XCTAssertTrue(chatNotification.title == "@john.appleseed", "notification title should be parsed correctly")
        XCTAssertTrue(chatNotification.payload.rid == "BBBBBBBBBBB", "notification rid should be parsed correctly")
        XCTAssertTrue(chatNotification.payload.sender == sender, "notification sender should be parsed correctly")
        XCTAssertTrue(chatNotification.payload.type == .directMessage, "notification message type should be parsed correctly")
        XCTAssertNil(chatNotification.payload.name, "notification room name should be nil")
    }

    func testPostingNotification() {
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
        notification.post()
        XCTAssert(NotificationManager.shared.notification == notification, "notification should be stored in the notification manager")
    }
}
