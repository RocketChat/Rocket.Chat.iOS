//
//  SubscriptionLastMessageSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 14/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class SubscriptionLastMessageSpec: XCTestCase {

    let defaultIdentifier = "message-identifier"

    override func setUp() {
        super.setUp()
        AppManager.resetLanguage()
    }

    func testEmptyUserMessage() {
        let message = Message()
        message.identifier = defaultIdentifier
        message.text = "foo"

        let lastMessage = Subscription.lastMessageText(lastMessage: message)
        XCTAssertEqual(lastMessage, "No message")
    }

    func testMarkdownMessageRemoval() {
        let user = User()
        user.username = "user_username"

        let message = Message()
        message.identifier = defaultIdentifier
        message.text = "**foo** *bar* [testing link](https://foo.bar)"
        message.user = user

        let lastMessage = Subscription.lastMessageText(lastMessage: message)
        XCTAssertEqual(lastMessage, "user_username: foo bar testing link")
    }

}
