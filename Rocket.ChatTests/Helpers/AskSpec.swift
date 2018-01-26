//
//  AskSpec.swift
//  Rocket.ChatTests
//
//  Created by Luca Justin Zimmermann on 26/01/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class AskSpec: XCTestCase {

    func testTitleMessage() {
        let title = "test"
        let message = "me"
        let ask = Ask(title: title, message: message)

        XCTAssert(ask.title == title, "Title matches")
        XCTAssert(ask.message == message, "Message matches")
        XCTAssert(ask.buttons[0] == localized("global.ok"), "First button is OK")
        XCTAssert(ask.buttons[1] == localized("global.cancel"), "Second button is Cancel")
        XCTAssert(ask.buttons.count == 2, "Two buttons")
        XCTAssertNil(ask.handlers[0])
        XCTAssertNil(ask.handlers[1])
    }

    func testKey() {
        let key = "alert.connection.invalid_url"
        let buttonA = "foo"
        let buttonB = "bar"
        let handler = ((UIAlertAction) -> Swift.Void)? { _ in
            return
        }
        let ask = Ask(key: key, buttonA: buttonA, handlerA: handler, buttonB: buttonB, handlerB: handler)

        XCTAssert(ask.title == localized(key + ".title"), "Title matches")
        XCTAssert(ask.message == localized(key + ".message"), "Message matches")
        XCTAssert(ask.buttons[0] == buttonA, "First button title matches")
        XCTAssert(ask.buttons[1] == buttonB, "Second button title matches")
        XCTAssert(ask.buttons.count == 2, "Two buttons")
        XCTAssertNotNil(ask.handlers[0], "HandlerA exists")
        XCTAssertNotNil(ask.handlers[1], "HandlerB exists")
    }

    func testIndividual() {
        let title = "test"
        let message = "me"
        let buttonA = "foo"
        let ask = Ask(title: title, message: message, buttons: [buttonA], handlers: [nil])

        XCTAssert(ask.title == title, "Title matches")
        XCTAssert(ask.buttons[0] == buttonA, "First button title matches")
        XCTAssert(ask.buttons.count == 1, "One button")
        XCTAssertNil(ask.handlers[0])
    }
}
