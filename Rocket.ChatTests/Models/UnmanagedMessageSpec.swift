//
//  UnmanagedMessageSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Streit on 11/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

final class UnmanagedMessageSpec: XCTestCase {

    override func tearDown() {
        super.tearDown()
        Realm.clearDatabase()
    }

    func testBasicMapping() {
        let testMessage = Message.testInstance()

        guard let unmanagedMessage = testMessage.unmanaged else {
            XCTFail("unamanged message was not created")
            return
        }

        XCTAssertEqual(unmanagedMessage.identifier, testMessage.identifier)
        XCTAssertEqual(unmanagedMessage.text, testMessage.text)
        XCTAssertEqual(unmanagedMessage.userIdentifier, testMessage.userIdentifier)
        XCTAssertEqual(unmanagedMessage.temporary, testMessage.temporary)
        XCTAssertEqual(unmanagedMessage.failed, testMessage.failed)
        XCTAssertEqual(unmanagedMessage.groupable, testMessage.groupable)
        XCTAssertEqual(unmanagedMessage.markedForDeletion, testMessage.markedForDeletion)
        XCTAssertEqual(unmanagedMessage.attachments.count, 0)
        XCTAssertEqual(unmanagedMessage.mentions.count, 0)
        XCTAssertEqual(unmanagedMessage.channels.count, 0)
        XCTAssertEqual(unmanagedMessage.reactions.count, 0)
        XCTAssertEqual(unmanagedMessage.urls.count, 0)
    }

    func testMentionsMapping() {
        let testMessage = Message.testInstance()

        let mention = Mention()
        mention.userId = "mention-user-id"
        mention.username = "mention-username"
        testMessage.mentions.append(mention)

        guard let unmanagedMessage = testMessage.unmanaged else {
            XCTFail("unamanged message was not created")
            return
        }

        XCTAssertEqual(unmanagedMessage.identifier, testMessage.identifier)
        XCTAssertEqual(unmanagedMessage.mentions.count, testMessage.mentions.count)
        XCTAssertEqual(unmanagedMessage.mentions.first?.userId, "mention-user-id")
        XCTAssertEqual(unmanagedMessage.mentions.first?.username, "mention-username")
    }

    func testChannelsMapping() {
        let testMessage = Message.testInstance()

        let channel = Channel()
        channel.name = "mention-channel"
        testMessage.channels.append(channel)

        guard let unmanagedMessage = testMessage.unmanaged else {
            XCTFail("unamanged message was not created")
            return
        }

        XCTAssertEqual(unmanagedMessage.identifier, testMessage.identifier)
        XCTAssertEqual(unmanagedMessage.channels.count, testMessage.channels.count)
        XCTAssertEqual(unmanagedMessage.channels.first?.name, "mention-channel")
    }

    func testURLsMapping() {
        let testMessage = Message.testInstance()

        let messageURL = MessageURL()
        messageURL.textDescription = "text-description"
        messageURL.title = "title"
        messageURL.targetURL = "target-url"
        messageURL.imageURL = "image-url"
        testMessage.urls.append(messageURL)

        guard let unmanagedMessage = testMessage.unmanaged else {
            XCTFail("unamanged message was not created")
            return
        }

        XCTAssertEqual(unmanagedMessage.identifier, testMessage.identifier)
        XCTAssertEqual(unmanagedMessage.urls.count, 1)
        XCTAssertEqual(unmanagedMessage.urls.first?.title, "title")
        XCTAssertEqual(unmanagedMessage.urls.first?.subtitle, "text-description")
        XCTAssertEqual(unmanagedMessage.urls.first?.imageURL, "image-url")
        XCTAssertEqual(unmanagedMessage.urls.first?.url, "target-url")
    }

    func testReactionsMapping() {
        let testMessage = Message.testInstance()

        let reaction = MessageReaction()
        reaction.emoji = ":+1:"
        reaction.usernames.append("username")
        testMessage.reactions.append(reaction)

        guard let unmanagedMessage = testMessage.unmanaged else {
            XCTFail("unamanged message was not created")
            return
        }

        XCTAssertEqual(unmanagedMessage.identifier, testMessage.identifier)
        XCTAssertEqual(unmanagedMessage.reactions.count, 1)
        XCTAssertEqual(unmanagedMessage.reactions.first?.emoji, ":+1:")
        XCTAssertEqual(unmanagedMessage.reactions.first?.usernames.first, "username")
    }

    func testDiscussionMapping() {
        let discussionDate = Date()

        let testMessage = Message.testInstance()
        testMessage.discussionRid = "rid"
        testMessage.discussionLastMessage = discussionDate
        testMessage.discussionMessagesCount = 100

        guard let unmanagedMessage = testMessage.unmanaged else {
            XCTFail("unamanged message was not created")
            return
        }

        XCTAssertEqual(unmanagedMessage.discussionRid, "rid")
        XCTAssertEqual(unmanagedMessage.discussionLastMessage, discussionDate)
        XCTAssertEqual(unmanagedMessage.discussionMessagesCount, 100)
    }

    func testThreadMapping() {
        let testMessage = Message.testInstance()
        testMessage.threadMessagesCount = 100
        testMessage.threadMessageId = "id123"

        guard let unmanagedMessage = testMessage.unmanaged else {
            XCTFail("unamanged message was not created")
            return
        }

        XCTAssertEqual(unmanagedMessage.threadMessagesCount, 100)
        XCTAssertEqual(unmanagedMessage.threadMessageId, "id123")
    }

    func testThreadMainMessageCheck() {
        let testMessage = Message.testInstance()
        testMessage.threadMessagesCount = 100

        guard let unmanagedMessage = testMessage.unmanaged else {
            XCTFail("unamanged message was not created")
            return
        }

        XCTAssertTrue(unmanagedMessage.isThreadMainMessage)
        XCTAssertFalse(unmanagedMessage.isThreadReplyMessage)
    }

    func testThreadReplyMessageCheck() {
        let testMessage = Message.testInstance()
        testMessage.threadMessageId = "id123"

        guard let unmanagedMessage = testMessage.unmanaged else {
            XCTFail("unamanged message was not created")
            return
        }

        XCTAssertFalse(unmanagedMessage.isThreadMainMessage)
        XCTAssertTrue(unmanagedMessage.isThreadReplyMessage)
    }

}
