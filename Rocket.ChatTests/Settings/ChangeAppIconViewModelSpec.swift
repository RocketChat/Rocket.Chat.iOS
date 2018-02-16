//
//  ChangeAppIconViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 10.02.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class ChangeAppIconViewModelSpec: XCTestCase {

    let model = ChangeAppIconViewModel()

    func testCellIdentifier() {
        XCTAssert(model.cellIdentifier == "changeAppIconCell", "incorrect cell's identifier")
    }

    func testAvailableIcons() {
        model.availableIcons.forEach { name in
            XCTAssertNotNil(UIImage(named: name), "There is no icon named \(name)")
        }
    }

    func testStringsOverall() {
        XCTAssertNotNil(model.title)
        XCTAssertNotEqual(model.title, "")

        XCTAssertNotNil(model.header)
        XCTAssertNotEqual(model.header, "")

        XCTAssertNotNil(model.errorTitle)
        XCTAssertNotEqual(model.errorTitle, "")

        XCTAssertNotNil(model.iosVersionMessage)
        XCTAssertNotEqual(model.iosVersionMessage, "")
    }
}
