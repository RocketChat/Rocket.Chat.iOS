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

}
