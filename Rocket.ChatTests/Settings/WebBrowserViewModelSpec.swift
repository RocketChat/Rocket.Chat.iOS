//
//  WebBrowserViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 23/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class WebBrowserViewModelSpec: XCTestCase {

    let model = WebBrowserViewModel()

    func testCellIdentifier() {
        XCTAssert(model.browserCellIdentifier == "WebBrowserCell", "incorrect cell's identifier")
    }

    func testAvailableBrowsers() {
        XCTAssertNotNil(model.browsers)
        XCTAssertTrue(model.browsers.count > 0, "There is no available browsers to choose")
    }

    func testStringsOverall() {
        XCTAssertNotNil(model.title)
        XCTAssertNotEqual(model.title, "")

        XCTAssertNotNil(model.footerTitle)
        XCTAssertNotEqual(model.footerTitle, "")
    }
}
