//
//  MessagesClientSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 12/7/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class MessagesClientSpec: XCTestCase, RealmTestCase {
    func testSendMessage() {
        let api = MockAPI()
        let realm = testRealm()
        let client = MessagesClient(api: api)

        api.nextResult = JSON([
            "success": true,
            "message": [
                "mentions": [],
                "_id": "a43SYFpMdjEAdM0mrH",
                "_updatedAt": "2017-12-07T12:30:38.384Z",
                "channels": [],
                "rid": "GENERAL",
                "u": [
                    "name": "Matheus Cardoso",
                    "username": "matheus.cardoso",
                    "_id": "ERoZg2xpgcDnXbCJu"
                ],
                "ts": "2017-12-07T12:30:38.382Z",
                "msg": "Test"
            ]
        ])

        let user = User.testInstance()
        let subscription = Subscription.testInstance()

        client.sendMessage(text: "test", subscription: subscription, id: "a43SYFpMdjEAdM0mrH", user: user, realm: realm)

        let messages = realm.objects(Message.self)
        XCTAssertEqual(messages.count, 1)
        XCTAssertEqual(realm.objects(Message.self).first?.temporary, true)

        let expectation = XCTestExpectation(description: "message updated in realm")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if realm.objects(Message.self).first?.temporary == false {
                expectation.fulfill()
            }
        })
        wait(for: [expectation], timeout: 0.6)
    }

    func testUpdateMessage() {
        let api = MockAPI()
        let realm = testRealm()
        let client = MessagesClient(api: api)

        let message = Message.testInstance()
        message.identifier = "message-identifier"

        try? realm.write {
            realm.add(message)
        }

        api.nextResult = JSON([
            "success": true,
            "message": [
                "_id": "message-identifier",
                "rid": "GENERAL",
                "msg": "edit-test",
                "ts": "2017-01-05T17:06:14.403Z",
                "u": [
                    "_id": "R4jgcQaQhvvK6K3iY",
                    "username": "graywolf336"
                ],
                "_updatedAt": "2017-01-05T19:42:20.433Z",
                "editedAt": "2017-01-05T19:42:20.431Z",
                "editedBy": [
                    "_id": "R4jgcQaQhvvK6K3iY",
                    "username": "graywolf336"
                ]
            ]
        ])

        client.updateMessage(message, text: "edit-test", realm: realm)

        let expectation = XCTestExpectation(description: "message updated in realm")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if realm.objects(Message.self).first?.text == "edit-test" {
                expectation.fulfill()
            }
        })
        wait(for: [expectation], timeout: 0.6)
    }
}
