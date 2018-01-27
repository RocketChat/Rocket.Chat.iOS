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
        XCTAssert(ask.buttons[0].title == localized("global.ok"), "First button is OK")
        XCTAssert(ask.buttons[1].title == localized("global.cancel"), "Second button is Cancel")
        XCTAssert(ask.buttons.count == 2, "Two buttons")
        XCTAssert(ask.deleteOption == -1, "No delete option")
        XCTAssertNil(ask.buttons[0].handler)
        XCTAssertNil(ask.buttons[1].handler)
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
        XCTAssert(ask.buttons[0].title == buttonA, "First button title matches")
        XCTAssert(ask.buttons[1].title == buttonB, "Second button title matches")
        XCTAssert(ask.buttons.count == 2, "Two buttons")
        XCTAssert(ask.deleteOption == -1, "No delete option")
        XCTAssertNotNil(ask.buttons[0].handler, "HandlerA exists")
        XCTAssertNotNil(ask.buttons[1].handler, "HandlerB exists")
    }

    func testIndividualTitleMessage() {
        let title = "test"
        let message = "me"
        let buttonA = "foo"
        let ask = Ask(title: title, message: message, buttons: [(title: buttonA, handler: nil)])

        XCTAssert(ask.title == title, "Title matches")
        XCTAssert(ask.buttons[0].title == buttonA, "First button title matches")
        XCTAssert(ask.buttons.count == 1, "One button")
        XCTAssert(ask.deleteOption == -1, "No delete option")
        XCTAssertNil(ask.buttons[0].handler)
    }

    func testIndividualKey() {
        let key = "alert.connection.invalid_url"
        let buttonA = "foo"
        let ask = Ask(key: key, buttons: [(title: buttonA, handler: nil)], deleteOption: 0)

        XCTAssert(ask.title == localized(key + ".title"), "Title matches")
        XCTAssert(ask.message == localized(key + ".message"), "Message matches")
        XCTAssert(ask.buttons[0].title == buttonA, "First button title matches")
        XCTAssert(ask.buttons.count == 1, "One button")
        XCTAssert(ask.deleteOption == 0, "Only delete option")
        XCTAssertNil(ask.buttons[0].handler)
    }
}
