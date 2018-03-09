//
//  LanguageViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 27.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class LanguageViewModelSpec: XCTestCase {

    let model = LanguageViewModel()

    func testCellIdentifier() {
        XCTAssert(model.cellIdentifier == "changeLanguageCell", "incorrect cell's identifier")
        XCTAssert(model.resetCellIdentifier == "changeLanguageResetCell", "incorrect cell's identifier")
    }

    func testAvailableLanguages() {
        XCTAssertNotNil(model.languages)
        XCTAssertTrue(model.languages.count > 0, "There is no available languages")
    }

    func testStringsOverall() {
        XCTAssertNotNil(model.title)
        XCTAssertNotEqual(model.title, "")

        XCTAssertNotNil(model.resetLabel)
        XCTAssertNotEqual(model.resetLabel, "")

        XCTAssertNotNil(model.message)
        XCTAssertNotEqual(model.message, "")
    }
}
