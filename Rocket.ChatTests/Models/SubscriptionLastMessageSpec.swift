//
//  SubscriptionLastMessageSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 14/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class SubscriptionLastMessageSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        AppManager.resetLanguage()
    }

    func testEmptyUserMessage() {
        let message = Message()
        message.text = "foo"
        message.createdAt = Date()
        message.identifier = String.random()

        let lastMessage = Subscription.lastMessageText(lastMessage: message)
        XCTAssertEqual(lastMessage, "No message")
    }

    func testMarkdownMessageRemoval() {
        let user = User()
        user.identifier = "user_identifier"
        user.username = "user_username"
        user.name = "user_name"

        let message = Message()
        message.identifier = String.random(20)
        message.createdAt = Date()
        message.text = "**foo** *bar* [testing link](https://foo.bar)"
        message.userIdentifier = user.identifier

        Realm.execute({ realm in
            realm.add(user, update: true)
            realm.add(message, update: true)
        })

        let lastMessage = Subscription.lastMessageText(lastMessage: message)
        XCTAssertEqual(lastMessage, "user_username: foo bar testing link")
    }

}
