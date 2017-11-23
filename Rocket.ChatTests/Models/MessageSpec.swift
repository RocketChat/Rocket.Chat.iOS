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

    static func testInstance() -> Message {
        let message = Message()
        message.user = User.testInstance()
        message.text = "message-text"
        message.subscription = Subscription.testInstance()
        message.identifier = "message-identifier"
        message.subscription.type = .channel
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
        XCTAssert(message.subscription.identifier == "message-subscription-1", "Message relationship with Subscription is OK")
        XCTAssert(message.user?.identifier == "message-user-1", "Message relationship with Subscription is OK")
    }

    func testMessageObjectFromJSON() {
        let object = JSON([
            "_id": "message-json-1",
            "rid": "123",
            "msg": "Foo Bar Baz",
            "ts": ["$date": 1234567891011],
            "_updatedAt": ["$date": 1234567891011],
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

        message.subscription.type = .channel
        XCTAssertEqual(message.quoteString, " [ ](https://open.rocket.chat/channel/subscription-name?msg=message-identifier)", "channel quoteString is correct")
        message.subscription.type = .group
        XCTAssertEqual(message.quoteString, " [ ](https://open.rocket.chat/group/subscription-name?msg=message-identifier)", "group quoteString is correct")
        message.subscription.type = .directMessage
        XCTAssertEqual(message.quoteString, " [ ](https://open.rocket.chat/direct/subscription-name?msg=message-identifier)", "dm quoteString is correct")

        message.identifier = nil
        XCTAssertNil(message.quoteString, "quoteString is nil when message identifier is nil")
        message.subscription.auth?.settings?.siteURL = nil
        XCTAssertNil(message.quoteString, "quoteString is nil when there's no siteURL")
    }

    func testReplyString() {
        let message = Message.testInstance()

        message.subscription.type = .channel
        XCTAssertEqual(message.replyString, " @user-username [ ](https://open.rocket.chat/channel/subscription-name?msg=message-identifier)", "channel replyString is correct")
        message.subscription.type = .group
        XCTAssertEqual(message.replyString, " @user-username [ ](https://open.rocket.chat/group/subscription-name?msg=message-identifier)", "group replyString is correct")
        message.subscription.type = .directMessage
        XCTAssertEqual(message.replyString, " [ ](https://open.rocket.chat/direct/subscription-name?msg=message-identifier)", "dm replyString is correct")

        message.identifier = nil
        XCTAssertNil(message.replyString, "replyString is nil when message identifier is nil")
        message.subscription.auth?.settings?.siteURL = nil
        XCTAssertNil(message.replyString, "replyString is nil when there's no siteURL")
    }

}
