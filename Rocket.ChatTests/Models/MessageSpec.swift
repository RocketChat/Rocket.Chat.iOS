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

// MARK: Test Instance

extension Message {

    static func testInstance(_ name: String = "message") -> Message {
        let message = Message()
        message.user = User.testInstance()
        message.text = "\(name)-text"
        message.rid = "\(name)-rid"
        message.subscription = Subscription.testInstance()
        message.identifier = "\(name)-identifier"
        message.subscription?.type = .channel
        message.createdAt = Date()
        return message
    }

}

class MessageSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        var uniqueConfiguration = Realm.Configuration.defaultConfiguration
        uniqueConfiguration.inMemoryIdentifier = NSUUID().uuidString
        Realm.Configuration.defaultConfiguration = uniqueConfiguration

        Realm.executeOnMainThread({ (realm) in
            realm.deleteAll()
        })
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
        message.user = user
        message.subscription = subscription

        XCTAssert(message.identifier == "message-object-1", "Message relationship with Subscription is OK")
        XCTAssert(message.subscription?.identifier == "message-subscription-1", "Message relationship with Subscription is OK")
        XCTAssert(message.user?.identifier == "message-user-1", "Message relationship with Subscription is OK")
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

// MARK: quoteString & replyString

extension MessageSpec {

    func testQuoteString() {
        let message = Message.testInstance()

        message.subscription?.type = .channel
        XCTAssertEqual(message.quoteString, " [ ](https://open.rocket.chat/channel/subscription-name?msg=message-identifier)", "channel quoteString is correct")
        message.subscription?.type = .group
        XCTAssertEqual(message.quoteString, " [ ](https://open.rocket.chat/group/subscription-name?msg=message-identifier)", "group quoteString is correct")
        message.subscription?.type = .directMessage
        XCTAssertEqual(message.quoteString, " [ ](https://open.rocket.chat/direct/subscription-name?msg=message-identifier)", "dm quoteString is correct")

        message.identifier = nil
        XCTAssertNil(message.quoteString, "quoteString is nil when message identifier is nil")
        message.subscription?.auth?.settings?.siteURL = nil
        XCTAssertNil(message.quoteString, "quoteString is nil when there's no siteURL")
    }

    func testReplyString() {
        let message = Message.testInstance()

        message.subscription?.type = .channel
        XCTAssertEqual(message.replyString, " @user-username [ ](https://open.rocket.chat/channel/subscription-name?msg=message-identifier)", "channel replyString is correct")
        message.subscription?.type = .group
        XCTAssertEqual(message.replyString, " @user-username [ ](https://open.rocket.chat/group/subscription-name?msg=message-identifier)", "group replyString is correct")
        message.subscription?.type = .directMessage
        XCTAssertEqual(message.replyString, " [ ](https://open.rocket.chat/direct/subscription-name?msg=message-identifier)", "dm replyString is correct")

        message.identifier = nil
        XCTAssertNil(message.replyString, "replyString is nil when message identifier is nil")
        message.subscription?.auth?.settings?.siteURL = nil
        XCTAssertNil(message.replyString, "replyString is nil when there's no siteURL")
    }

}

// MARK: Broadcast

extension MessageSpec: RealmTestCase {

    func testMessageBroadcastTrue() {
        let realm = testRealm()

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

        Realm.executeOnMainThread(realm: realm, { realm in
            realm.add(auth)
            realm.add(user)
        })

        let subscription = Subscription()
        subscription.identifier = "1"
        subscription.roomBroadcast = true

        let message = Message()
        message.subscription = subscription
        message.text = "foobar"
        message.user = userOther

        XCTAssertTrue(message.isBroadcastReplyAvailable(realm: realm))
    }

    func testMessageSystemBroadcastFalse() {
        let subscription = Subscription()
        subscription.identifier = "1"
        subscription.roomBroadcast = true

        let message = Message()
        message.subscription = subscription
        message.internalType = MessageType.roomArchived.rawValue

        XCTAssertFalse(message.isBroadcastReplyAvailable())
    }

    func testMessageTemporaryBroadcastFalse() {
        let subscription = Subscription()
        subscription.identifier = "1"
        subscription.roomBroadcast = true

        let message = Message()
        message.subscription = subscription
        message.text = "foobar"
        message.temporary = true

        XCTAssertFalse(message.isBroadcastReplyAvailable())
    }

    func testMessageFailedBroadcastFalse() {
        let subscription = Subscription()
        subscription.identifier = "1"
        subscription.roomBroadcast = true

        let message = Message()
        message.subscription = subscription
        message.text = "foobar"
        message.failed = true

        XCTAssertFalse(message.isBroadcastReplyAvailable())
    }

    func testMessageCurrentUserBroadcastFalse() {
        let subscription = Subscription()
        subscription.identifier = "1"
        subscription.roomBroadcast = true

        let message = Message()
        message.subscription = subscription
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
