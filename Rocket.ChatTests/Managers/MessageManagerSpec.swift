//
//  MessageManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class MessageManagerSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        // Clear all the Message objects in Realm
        Realm.execute { realm in
            for obj in realm.objects(Message.self) {
                realm.delete(obj)
            }

            for obj in realm.objects(Subscription.self) {
                realm.delete(obj)
            }
        }
    }

}

// MARK: Realm Data Tests

extension MessageManagerSpec {

    func testAllMessagesReturnsOnlyRelatedToSubscription() {
        let subscription1 = Subscription()
        subscription1.identifier = "subs1"

        let message1 = Message()
        message1.identifier = "msg1"
        message1.subscription = subscription1

        let subscription2 = Subscription()
        subscription2.identifier = "subs2"

        let message2 = Message()
        message2.identifier = "msg2"
        message2.subscription = subscription2

        Realm.execute { realm in
            realm.add([subscription1, subscription2, message1, message2])
        }

        let messages1 = subscription1.fetchMessages()
        let messages2 = subscription2.fetchMessages()

        XCTAssert(messages1.count == 1, "fetchMessages() will return all messages related to the subscription")
        XCTAssert(messages2.count == 1, "fetchMessages() will return all messages related to the subscription")
        XCTAssert(messages1[0].identifier == message1.identifier, "fetchMessages() will return just messages related to the subscription")
        XCTAssert(messages2[0].identifier == message2.identifier, "fetchMessages() will return just messages related to the subscription")
    }

    func testAllMessagesReturnsMessagesOrderedByDate() {
        let subscription = Subscription()
        subscription.identifier = "subscription"

        let message1 = Message()
        message1.identifier = "msg1"
        message1.createdAt = Date(timeIntervalSinceNow: -100)
        message1.subscription = subscription

        let message2 = Message()
        message2.identifier = "msg2"
        message2.createdAt = Date(timeIntervalSinceNow: 0)
        message2.subscription = subscription

        Realm.execute { realm in
            realm.add([subscription, message1, message2])
        }

        let messages = subscription.fetchMessages()
        XCTAssert(messages.count == 2, "fetchMessages() will return all messages related to the subscription")
        XCTAssert(messages[0].identifier == message1.identifier, "fetchMessages() will return messages ordered by date")
        XCTAssert(messages[1].identifier == message2.identifier, "fetchMessages() will return messages ordered by date")
    }

}
