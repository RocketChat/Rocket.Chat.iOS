//
//  MessageManagerSystemMessageSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 10/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

final class MessageManagerSystemMessageSpec: XCTestCase, RealmTestCase {

    func testSystemMessageCreationBasic() {
        let realm = testRealm()

        let subscriptionIdentifier = "systemMessageSubscription_1"
        let subscription = Subscription()
        subscription.rid = subscriptionIdentifier

        realm.execute({ _ in
            realm.add(subscription)
        })

        let messageIdentifier = "systemMessageBasic_1"
        let messageText = "Basic"

        let object = JSON([
            "_id": messageIdentifier,
            "msg": messageText,
            "rid": subscriptionIdentifier
        ])

        if let basicObject = object.dictionary {
            MessageManager.createSystemMessage(from: basicObject, realm: realm)

            let expectation = XCTestExpectation(description: "message should have been created")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                let message = realm.objects(Message.self).filter("identifier = '\(messageIdentifier)'").first
                XCTAssertEqual(message?.text, messageText)
                XCTAssertEqual(message?.user?.username, "rocket.cat")
                XCTAssertNil(message?.avatar)
                XCTAssertTrue(message?.privateMessage ?? false)

                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 3)
        } else {
            XCTFail("basic object is not valid")
        }
    }

    func testSystemMessageCreationBasicWithAvatar() {
        let realm = testRealm()

        let subscriptionIdentifier = "systemMessageSubscription_1"
        let subscription = Subscription()
        subscription.rid = subscriptionIdentifier

        realm.execute({ _ in
            realm.add(subscription)
        })

        let messageIdentifier = "systemMessageBasic_2"
        let messageText = "Basic with Avatar"
        let avatarURL = "http://rocket.chat"

        let object = JSON([
            "_id": messageIdentifier,
            "msg": messageText,
            "rid": subscriptionIdentifier,
            "avatar": avatarURL
        ])

        if let basicObject = object.dictionary {
            MessageManager.createSystemMessage(from: basicObject, realm: realm)

            let expectation = XCTestExpectation(description: "message should have been created")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                let message = realm.objects(Message.self).filter("identifier = '\(messageIdentifier)'").first
                XCTAssertEqual(message?.text, messageText)
                XCTAssertEqual(message?.user?.username, "rocket.cat")
                XCTAssertEqual(message?.avatar, avatarURL)
                XCTAssertTrue(message?.privateMessage ?? false)

                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 3)
        } else {
            XCTFail("basic object is not valid")
        }
    }

    func testSystemMessageCreationWithCustomUser() {
        let realm = testRealm()

        let subscriptionIdentifier = "systemMessageSubscription_1"
        let subscription = Subscription()
        subscription.rid = subscriptionIdentifier

        let userIdentifier = "systemMessageUser_1"
        let user = User()
        user.identifier = userIdentifier
        user.username = userIdentifier

        realm.execute({ _ in
            realm.add(subscription)
        })

        let messageIdentifier = "systemMessageBasic_2"
        let messageText = "Basic with Avatar"

        let object = JSON([
            "_id": messageIdentifier,
            "msg": messageText,
            "rid": subscriptionIdentifier,
            "u": ["_id": userIdentifier]
        ])

        if let basicObject = object.dictionary {
            MessageManager.createSystemMessage(from: basicObject, realm: realm)

            let expectation = XCTestExpectation(description: "message should have been created")
            DispatchQueue.main.asyncAfter(deadline: .now() + 2, execute: {
                let message = realm.objects(Message.self).filter("identifier = '\(messageIdentifier)'").first
                XCTAssertEqual(message?.text, messageText)
                XCTAssertEqual(message?.user?.identifier, userIdentifier)
                XCTAssertTrue(message?.privateMessage ?? false)

                expectation.fulfill()
            })
            wait(for: [expectation], timeout: 3)
        } else {
            XCTFail("basic object is not valid")
        }
    }

}
