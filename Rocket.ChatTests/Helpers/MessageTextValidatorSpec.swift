//
//  MessageTextValidatorSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class MessageTextValidatorSpec: XCTestCase {

    func testNegativeSizeResponse() {
        let settings = AuthSettings()
        settings.messageMaxAllowedSize = -100

        AuthSettingsManager.shared.internalSettings = settings

        XCTAssertTrue(MessageTextValidator.isSizeValid(text: "test with negative allowed size"))
    }

    func testZeroSizeResponse() {
        let settings = AuthSettings()
        settings.messageMaxAllowedSize = 0

        AuthSettingsManager.shared.internalSettings = settings

        XCTAssertTrue(MessageTextValidator.isSizeValid(text: "test with zero allowed size"))
    }

    func testPositiveSizeResponse() {
        let settings = AuthSettings()
        settings.messageMaxAllowedSize = 5

        AuthSettingsManager.shared.internalSettings = settings

        XCTAssertTrue(MessageTextValidator.isSizeValid(text: "there"))
        XCTAssertFalse(MessageTextValidator.isSizeValid(text: "there is"))
    }

    func testPositiveSizeResponseWithEmojis() {
        let settings = AuthSettings()
        settings.messageMaxAllowedSize = 18

        AuthSettingsManager.shared.internalSettings = settings

        // 👨‍👨‍👦‍👦 means 11 in utf16
        XCTAssertTrue(MessageTextValidator.isSizeValid(text: "there 👨‍👨‍👦‍👦"))
        XCTAssertFalse(MessageTextValidator.isSizeValid(text: "there is 👨‍👨‍👦‍👦"))
    }

}
