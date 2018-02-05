//
//  AskSpec.swift
//  Rocket.ChatTests
//
//  Created by Luca Justin Zimmermann on 26/01/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class AlertSpec: XCTestCase {

    func testTitleMessage() {
        let title = "test"
        let message = "me"
        let alert = Alert(title: title, message: message)

        XCTAssert(alert.title == title, "Title matches")
        XCTAssert(alert.message == message, "Message matches")
    }

    func testKey() {
        let key = "alert.connection.invalid_url"
        let alert = Alert(key: key)

        XCTAssert(alert.title == localized(key + ".title"), "Title matches")
        XCTAssert(alert.message == localized(key + ".message"), "Message matches")
    }
}
