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

    override func tearDown() {
        super.tearDown()
        Realm.clearDatabase()
    }

    func testAllMessagesReturnsOnlyRelatedToSubscription() {
        Realm.execute({ realm in
            let subscription1 = Subscription()
            subscription1.identifier = "subs1"
            subscription1.rid = "subs-1-rid"

            let message1 = Message()
            message1.identifier = "msg1"
            message1.rid = subscription1.rid
            message1.createdAt = Date()

            let subscription2 = Subscription()
            subscription2.identifier = "subs2"
            subscription2.rid = "subs-2-rid"

            let message2 = Message()
            message2.identifier = "msg2"
            message2.rid = subscription2.rid
            message2.createdAt = Date()

            realm.add([subscription1, subscription2, message1, message2], update: true)

            let messages1 = subscription1.fetchMessages()
            let messages2 = subscription2.fetchMessages()

            XCTAssertEqual(messages1.count, 1, "fetchMessages() will return all messages related to the subscription")
            XCTAssertEqual(messages2.count, 1, "fetchMessages() will return all messages related to the subscription")
            XCTAssertEqual(messages1[0].identifier, message1.identifier, "fetchMessages() will return just messages related to the subscription")
            XCTAssertEqual(messages2[0].identifier, message2.identifier, "fetchMessages() will return just messages related to the subscription")
        })
    }

    func testAllMessagesReturnsMessagesOrderedByDate() {
        Realm.execute({ realm in
            let subscription = Subscription()
            subscription.identifier = "subscription"

            let message1 = Message()
            message1.identifier = "msg1"
            message1.createdAt = Date(timeIntervalSinceNow: -100)
            message1.rid = subscription.rid

            let message2 = Message()
            message2.identifier = "msg2"
            message2.createdAt = Date(timeIntervalSinceNow: 0)
            message2.rid = subscription.rid

            realm.add([subscription, message1, message2])

            guard let messages = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messages.count == 2, "fetchMessages() will return all messages related to the subscription")
            XCTAssert(messages[1].identifier == message2.identifier, "fetchMessages() will return messages ordered by date")
            XCTAssert(messages[0].identifier == message1.identifier, "fetchMessages() will return messages ordered by date")
        })
    }

    func testHideMessagesUserJoined() {
        Realm.execute({ realm in
            let subscription = Subscription()
            subscription.identifier = "subscription"
            realm.add([subscription])

            AuthSettingsManager.shared.internalSettings = AuthSettings()

            let message1 = Message()
            message1.identifier = "msg1"
            message1.rid = subscription.rid
            message1.createdAt = Date()
            realm.add([message1])

            message1.internalType = MessageType.userJoined.rawValue

            AuthSettingsManager.settings?.hideMessageUserJoined = false
            guard let messages = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messages.count == 1, "fetchMessages() will return userJoined when it's not hidden")

            AuthSettingsManager.settings?.hideMessageUserJoined = true
            guard let messagesFiltered = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messagesFiltered.count == 0, "fetchMessages() will not return userJoined when it's hidden")
        })
    }

    func testHideMessagesUserLeft() {
        Realm.execute({ realm in
            let subscription = Subscription()
            subscription.identifier = "subscription"
            realm.add([subscription])

            AuthSettingsManager.shared.internalSettings = AuthSettings()

            let message1 = Message()
            message1.identifier = "msg1"
            message1.rid = subscription.rid
            message1.createdAt = Date()
            realm.add([message1])

            // userLeft

            message1.internalType = MessageType.userLeft.rawValue

            AuthSettingsManager.settings?.hideMessageUserLeft = false

            guard let messages = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messages.count == 1, "fetchMessages() will return userLeft when it's not hidden")

            AuthSettingsManager.settings?.hideMessageUserLeft = true
            guard let messagesFiltered = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messagesFiltered.count == 0, "fetchMessages() will not return userLeft when it's hidden")
        })
    }

    func testHideMessagesUserAdded() {
        Realm.execute({ realm in
            let subscription = Subscription()
            subscription.identifier = "subscription"
            realm.add([subscription])

            AuthSettingsManager.shared.internalSettings = AuthSettings()

            let message1 = Message()
            message1.identifier = "msg1"
            message1.rid = subscription.rid
            message1.createdAt = Date()
            realm.add([message1])

            // userAdded

            message1.internalType = MessageType.userAdded.rawValue

            AuthSettingsManager.settings?.hideMessageUserAdded = false

            guard let messages = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messages.count == 1, "fetchMessages() will return userAdded when it's not hidden")

            AuthSettingsManager.settings?.hideMessageUserAdded = true
            guard let messagesFiltered = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messagesFiltered.count == 0, "fetchMessages() will not return userAdded when it's hidden")
        })
    }

    func testHideMessagesUserRemoved() {
        Realm.execute({ realm in
            let subscription = Subscription()
            subscription.identifier = "subscription"
            realm.add([subscription])

            AuthSettingsManager.shared.internalSettings = AuthSettings()

            let message1 = Message()
            message1.identifier = "msg1"
            message1.rid = subscription.rid
            message1.createdAt = Date()
            realm.add([message1])

            message1.internalType = MessageType.userRemoved.rawValue

            AuthSettingsManager.settings?.hideMessageUserRemoved = false

            guard let messages = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messages.count == 1, "fetchMessages() will return userRemoved when it's not hidden")

            AuthSettingsManager.settings?.hideMessageUserRemoved = true
            guard let messagesFiltered = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messagesFiltered.count == 0, "fetchMessages() will not return userRemoved when it's hidden")
        })
    }

    func testHideMessagesUserMutedUnmuted() {
        Realm.execute({ realm in
            let subscription = Subscription()
            subscription.identifier = "subscription"
            realm.add([subscription])

            AuthSettingsManager.shared.internalSettings = AuthSettings()

            let message1 = Message()
            message1.identifier = "msg1"
            message1.rid = subscription.rid
            message1.createdAt = Date()
            realm.add([message1])

            message1.internalType = MessageType.userMuted.rawValue

            let message2 = Message()
            message2.identifier = "message2"
            message2.internalType = MessageType.userUnmuted.rawValue
            message2.rid = subscription.rid
            message2.createdAt = Date()
            realm.add([message2])

            AuthSettingsManager.settings?.hideMessageUserMutedUnmuted = false

            guard let messages = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messages.count == 2, "fetchMessages() will return userMuted or userUnmuted when they're not hidden")

            AuthSettingsManager.settings?.hideMessageUserMutedUnmuted = true
            guard let messagesFiltered = subscription.fetchMessagesQueryResults() else {
                return XCTFail("messages are not valid")
            }

            XCTAssert(messagesFiltered.count == 0, "fetchMessages() will not return userMuted or userUnmuted when they're hidden")
        })
    }

}
