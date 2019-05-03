//
//  MessageSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

// swiftlint:disable file_length

// MARK: Test Instance

extension Message {

    static func testInstance(_ name: String = "message") -> Message {
        let subscription = Subscription.testInstance()
        let message = Message()
        message.userIdentifier = User.testInstance().identifier
        message.text = "\(name)-text"
        message.rid = subscription.rid
        message.identifier = "\(name)-identifier"
        message.subscription?.type = .channel
        message.createdAt = Date()
        return message
    }

}

class MessageSpec: XCTestCase {

    override func tearDown() {
        super.tearDown()
        Realm.clearDatabase()
    }

    func testStarred() {
        let message = Message()

        let values = JSON([
            "_id": "message-json-1",
            "rid": "123",
            "msg": "Foo Bar Baz",
            "ts": ["$date": 123456789],
            "_updatedAt": ["$date": 123456789],
            "u": ["_id": "123", "username": "foo"],
            "starred": [["_id": "userid1"], ["_id": "userid2"], ["_id": "userid3"]]
        ])

        message.map(values, realm: nil)

        XCTAssertEqual(message.starred.count, 3, "message is mapping 'starred' correctly")
    }

    func testSubscriptionObject() {
        let auth = Auth()
        auth.serverURL = "http://foo.bar.baz"

        let subscription = Subscription()
        subscription.auth = auth
        subscription.identifier = "message-subscription-1"

        let user = User()
        user.identifier = "message-user-1"

        let message = Message()
        message.identifier = "message-object-1"
        message.text = "text"
        message.userIdentifier = user.identifier
        message.rid = subscription.rid

        Realm.execute({ realm in
            realm.add(auth, update: true)
            realm.add(subscription, update: true)
            realm.add(user, update: true)
            realm.add(message, update: true)
        })

        XCTAssertEqual(message.identifier, "message-object-1", "Message relationship with Subscription is OK")
        XCTAssertEqual(message.subscription?.identifier, "message-subscription-1", "Message relationship with Subscription is OK")
        XCTAssertEqual(message.user?.identifier, "message-user-1", "Message relationship with User is OK")
    }

    func testMessageObjectFromJSON() {
        let object = JSON([
            "_id": "message-json-1",
            "rid": "123",
            "msg": "Foo Bar Baz",
            "ts": ["$date": 123456789],
            "_updatedAt": ["$date": 123456789],
            "u": ["_id": "123", "username": "foo"]
        ])

        let message = Message()
        message.map(object, realm: nil)
        XCTAssert(message.identifier == "message-json-1", "Message object was created with success")
    }

    func testDiscussionMessageObjectFromJSON() {
        let object = JSON([
            "_id": "message-json-1",
            "rid": "123",
            "msg": "Foo Bar Baz",
            "ts": ["$date": 123456789],
            "_updatedAt": ["$date": 123456789],
            "u": ["_id": "123", "username": "foo"],
            "drid": "123drid",
            "dlm": ["$date": 123456789],
            "dcount": 100
        ])

        let message = Message()
        message.map(object, realm: nil)

        XCTAssertEqual(message.discussionRid, "123drid", "discussionRid was mapped correctly")
        XCTAssertEqual(message.discussionLastMessage, Date.dateFromInterval(123456789), "discussionLastMessage was mapped correctly")
        XCTAssertEqual(message.discussionMessagesCount, 100, "discussionMessagesCount was mapped correctly")
    }

    func testMessageTypeAttachmentImage() {
        let attachment = Attachment()
        attachment.imageURL = "https://foo.bar"

        let message = Message.testInstance()
        message.attachments.removeAll()
        message.attachments.append(attachment)

        XCTAssertEqual(message.type, .image, "message type is image")
    }

    func testMessageTypeAttachmentVideo() {
        let attachment = Attachment()
        attachment.videoURL = "https://foo.bar"

        let message = Message.testInstance()
        message.attachments.removeAll()
        message.attachments.append(attachment)

        XCTAssertEqual(message.type, .video, "message type is video")
    }

    func testMessageTypeAttachmentAudio() {
        let attachment = Attachment()
        attachment.audioURL = "https://foo.bar"

        let message = Message.testInstance()
        message.attachments.removeAll()
        message.attachments.append(attachment)

        XCTAssertEqual(message.type, .audio, "message type is audio")
    }

    func testMessageTypeAttachmentDefault() {
        let attachment = Attachment()

        let message = Message.testInstance()
        message.attachments.removeAll()
        message.attachments.append(attachment)

        XCTAssertEqual(message.type, .textAttachment, "message type is textAttachment")
    }

    func testMessageTypeURLValid() {
        let messageURL = MessageURL.testInstance()

        let message = Message.testInstance()
        message.urls.removeAll()
        message.urls.append(messageURL)

        XCTAssertEqual(message.type, .url, "message type is url")
    }

    func testMessageTypeURLInvalid() {
        let messageURL = MessageURL.testInstance()
        messageURL.title = ""

        let message = Message.testInstance()
        message.urls.removeAll()
        message.urls.append(messageURL)

        XCTAssertEqual(message.type, .text, "message type is text")
    }

}

// MARK: quoteString

extension MessageSpec {

    func testQuoteString() {
        let subscription = Subscription.testInstance()

        let message = Message.testInstance()
        message.rid = subscription.rid

        Realm.execute({ realm in
            subscription.type = .channel
            realm.add(subscription, update: true)
            realm.add(message, update: true)
        })

        XCTAssertEqual(message.quoteString, " [ ](https://open.rocket.chat/channel/subscription-name?msg=message-identifier)", "channel quoteString is correct")

        Realm.execute({ realm in
            subscription.type = .group
            realm.add(subscription, update: true)
        })

        XCTAssertEqual(message.quoteString, " [ ](https://open.rocket.chat/group/subscription-name?msg=message-identifier)", "group quoteString is correct")

        Realm.execute({ realm in
            subscription.type = .directMessage
            realm.add(subscription, update: true)
        })

        XCTAssertEqual(message.quoteString, " [ ](https://open.rocket.chat/direct/subscription-name?msg=message-identifier)", "dm quoteString is correct")
    }

}

// MARK: Broadcast

extension MessageSpec {

    func testMessageBroadcastTrue() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        let auth = Auth()
        auth.serverURL = "https://foo.com/"
        auth.token = "123"
        auth.tokenExpires = Date()
        auth.lastAccess = Date()
        auth.userId = "1"

        let user = User()
        user.identifier = "1"

        let userOther = User()
        userOther.identifier = "2"

        realm.execute({ realm in
            realm.add(auth)
            realm.add(user)
        })

        let subscription = Subscription()
        subscription.identifier = "1"
        subscription.roomBroadcast = true

        let message = Message()
        message.rid = subscription.rid
        message.text = "foobar"
        message.userIdentifier = userOther.identifier

        Realm.execute({ realm in
            realm.add(subscription, update: true)
            realm.add(message, update: true)
        })

        XCTAssertTrue(message.isBroadcastReplyAvailable(realm: realm))
    }

    func testMessageSystemBroadcastFalse() {
        let subscription = Subscription()
        subscription.identifier = "1"
        subscription.roomBroadcast = true

        let message = Message()
        message.rid = subscription.rid
        message.internalType = MessageType.roomArchived.rawValue

        XCTAssertFalse(message.isBroadcastReplyAvailable())
    }

    func testMessageTemporaryBroadcastFalse() {
        let subscription = Subscription()
        subscription.identifier = "1"
        subscription.roomBroadcast = true

        let message = Message()
        message.rid = subscription.rid
        message.text = "foobar"
        message.temporary = true

        XCTAssertFalse(message.isBroadcastReplyAvailable())
    }

    func testMessageFailedBroadcastFalse() {
        let subscription = Subscription()
        subscription.identifier = "1"
        subscription.roomBroadcast = true

        let message = Message()
        message.rid = subscription.rid
        message.text = "foobar"
        message.failed = true

        XCTAssertFalse(message.isBroadcastReplyAvailable())
    }

    func testMessageCurrentUserBroadcastFalse() {
        let subscription = Subscription()
        subscription.identifier = "1"
        subscription.roomBroadcast = true

        let message = Message()
        message.rid = subscription.rid
        message.text = "foobar"
        message.failed = true

        XCTAssertFalse(message.isBroadcastReplyAvailable())
    }

}

// MARK: Equatable

extension MessageSpec {

    func testEqualMessagesTrue() {
        let updatedAt = Date()

        let message1 = Message()
        message1.identifier = "identifier"
        message1.updatedAt = updatedAt

        let message2 = Message()
        message2.identifier = "identifier"
        message2.updatedAt = updatedAt

        XCTAssertTrue(message1 == message2)
    }

    func testEqualMessagesFalse() {
        let message1 = Message()
        message1.identifier = "identifier"
        message1.updatedAt = Date().addingTimeInterval(60)

        let message2 = Message()
        message2.identifier = "identifier"
        message2.updatedAt = Date().addingTimeInterval(120)

        XCTAssertFalse(message1 == message2)
    }

    func testEqualMessagesMentionsFalse() {
        let updatedAt = Date()

        let mentions = List<Mention>()
        let mention = Mention()
        mention.username = "foobar"
        mentions.append(mention)

        let message1 = Message()
        message1.identifier = "identifier"
        message1.updatedAt = updatedAt

        let message2 = Message()
        message2.identifier = "identifier"
        message2.updatedAt = updatedAt
        message2.mentions = mentions

        XCTAssertFalse(message1 == message2)
    }

    func testEqualMessagesChannelsFalse() {
        let updatedAt = Date()

        let channels = List<Channel>()
        let channel = Channel()
        channel.name = "foobar"
        channels.append(channel)

        let message1 = Message()
        message1.identifier = "identifier"
        message1.updatedAt = updatedAt

        let message2 = Message()
        message2.identifier = "identifier"
        message2.updatedAt = updatedAt
        message2.channels = channels

        XCTAssertFalse(message1 == message2)
    }

    func testEqualMessagesTemporaryFalse() {
        let updatedAt = Date()

        let message1 = Message()
        message1.identifier = "identifier"
        message1.updatedAt = updatedAt
        message1.temporary = true

        let message2 = Message()
        message2.identifier = "identifier"
        message2.updatedAt = updatedAt
        message2.temporary = false

        XCTAssertFalse(message1 == message2)
    }

    func testEqualMessagesFailedFalse() {
        let updatedAt = Date()

        let message1 = Message()
        message1.identifier = "identifier"
        message1.updatedAt = updatedAt
        message1.failed = true

        let message2 = Message()
        message2.identifier = "identifier"
        message2.updatedAt = updatedAt
        message2.failed = false

        XCTAssertFalse(message1 == message2)
    }

}
