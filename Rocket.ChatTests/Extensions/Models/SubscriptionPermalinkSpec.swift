//
//  SubscriptionPermalinkSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 20/12/2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import XCTest
import RealmSwift

@testable import Rocket_Chat

class SubscriptionPermalinkSpec: XCTestCase {
    lazy var realm: Realm = {
        let configuration = Realm.Configuration(inMemoryIdentifier: "SubscriptionPermalinkSpecRealm")
        if let realm = try? Realm(configuration: configuration) {
            return realm
        }

        fatalError("Could not instantiate test realm")
    }()

    override func tearDown() {
        super.tearDown()
        try? realm.write {
            realm.deleteAll()
        }
    }

    func testPermalink() throws {
        let subscription = Subscription.testInstance()
        subscription.name = "test-channel"
        subscription.type = .channel
        subscription.auth?.serverURL = "https://test.rocket.chat/"

        try? realm.write {
            realm.add(subscription)
        }

        let link0 = subscription.permalink(messageIdentifier: "message-identifier")
        XCTAssertEqual(
            link0,
            "https://test.rocket.chat/channel/test-channel?msg=message-identifier",
            "permalink works for channel"
        )

        try? realm.write {
            subscription.type = .group
        }

        let link1 = subscription.permalink(messageIdentifier: "message-identifier")
        XCTAssertEqual(
            link1,
            "https://test.rocket.chat/group/test-channel?msg=message-identifier",
            "permalink works for group"
        )

        try? realm.write {
            subscription.type = .directMessage
        }

        let link2 = subscription.permalink(messageIdentifier: "message-identifier")
        XCTAssertEqual(
            link2,
            "https://test.rocket.chat/direct/test-channel?msg=message-identifier",
            "permalink works for dm"
        )

        let link3 = subscription.permalink()
        XCTAssertEqual(
            link3,
            "https://test.rocket.chat/direct/test-channel",
            "permalink works without message id"
        )
    }

    func testCopyPermalink() throws {
        let realm = try Realm(configuration: Realm.Configuration(inMemoryIdentifier: "testPermalinkSpec"))

        let subscription = Subscription.testInstance()
        subscription.name = "test-channel"
        subscription.type = .channel
        subscription.auth?.serverURL = "https://test.rocket.chat/"

        try? realm.write {
            realm.add(subscription)
        }

        subscription.copyPermalink(messageIdentifier: "message-identifier")

        XCTAssertEqual(
            UIPasteboard.general.string,
            "https://test.rocket.chat/channel/test-channel?msg=message-identifier",
            "permalink is copied to clipboard"
        )
    }
}
