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
        Realm.executeOnMainThread({ realm in
            realm.deleteAll()
        })
    }

}

// MARK: Realm Data Tests

extension MessageManagerSpec {

    func testAllMessagesReturnsOnlyRelatedToSubscription() {
        Realm.executeOnMainThread({ realm in
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

            realm.add([subscription1, subscription2, message1, message2], update: true)

            let messages1 = subscription1.fetchMessages()
            let messages2 = subscription2.fetchMessages()

            XCTAssert(messages1.count == 1, "fetchMessages() will return all messages related to the subscription")
            XCTAssert(messages2.count == 1, "fetchMessages() will return all messages related to the subscription")
            XCTAssert(messages1[0].identifier == message1.identifier, "fetchMessages() will return just messages related to the subscription")
            XCTAssert(messages2[0].identifier == message2.identifier, "fetchMessages() will return just messages related to the subscription")
        })
    }

    func testAllMessagesReturnsMessagesOrderedByDate() {
        Realm.executeOnMainThread({ realm in
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

            realm.add([subscription, message1, message2])

            let messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 2, "fetchMessages() will return all messages related to the subscription")
            XCTAssert(messages[0].identifier == message2.identifier, "fetchMessages() will return messages ordered by date")
            XCTAssert(messages[1].identifier == message1.identifier, "fetchMessages() will return messages ordered by date")
        })
    }

    func testAllMessagesReturnsMessagesNotHidden() {
        Realm.executeOnMainThread({ realm in
            let subscription = Subscription()
            subscription.identifier = "subscription"
            realm.add([subscription])

            AuthSettingsManager.shared.internalSettings = AuthSettings()

            let message1 = Message()
            message1.identifier = "msg1"
            message1.subscription = subscription
            realm.add([message1])

            // userJoined

            message1.internalType = MessageType.userJoined.rawValue

            AuthSettingsManager.settings?.hideMessageUserJoined = false
            var messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 1, "fetchMessages() will return userJoined when it's not hidden")
            AuthSettingsManager.settings?.hideMessageUserJoined = true
            messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 0, "fetchMessages() will not return userJoined when it's hidden")

            // userLeft

            message1.internalType = MessageType.userLeft.rawValue

            AuthSettingsManager.settings?.hideMessageUserLeft = false
            messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 1, "fetchMessages() will return userLeft when it's not hidden")
            AuthSettingsManager.settings?.hideMessageUserLeft = true
            messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 0, "fetchMessages() will not return userLeft when it's hidden")

            // userAdded

            message1.internalType = MessageType.userAdded.rawValue

            AuthSettingsManager.settings?.hideMessageUserAdded = false
            messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 1, "fetchMessages() will return userAdded when it's not hidden")
            AuthSettingsManager.settings?.hideMessageUserAdded = true
            messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 0, "fetchMessages() will not return userAdded when it's hidden")

            // userRemoved

            message1.internalType = MessageType.userRemoved.rawValue

            AuthSettingsManager.settings?.hideMessageUserRemoved = false
            messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 1, "fetchMessages() will return userRemoved when it's not hidden")
            AuthSettingsManager.settings?.hideMessageUserRemoved = true
            messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 0, "fetchMessages() will not return userRemoved when it's hidden")

            // userMutedUnmuted

            message1.internalType = MessageType.userMuted.rawValue

            let message2 = Message()
            message2.identifier = "message2"
            message2.internalType = MessageType.userUnmuted.rawValue
            message2.subscription = subscription
            realm.add([message2])

            AuthSettingsManager.settings?.hideMessageUserMutedUnmuted = false
            messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 2, "fetchMessages() will return userMuted or userUnmuted when they're not hidden")
            AuthSettingsManager.settings?.hideMessageUserMutedUnmuted = true
            messages = subscription.fetchMessagesQueryResults()
            XCTAssert(messages.count == 0, "fetchMessages() will not return userMuted or userUnmuted when they're hidden")
        })
    }
}
