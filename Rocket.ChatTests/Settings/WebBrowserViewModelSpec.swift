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

    func testStringsOverall() {
        XCTAssertNotNil(model.title)
        XCTAssertNotEqual(model.title, "")

        XCTAssertNotNil(model.footerTitle)
        XCTAssertNotEqual(model.footerTitle, "")
    }
}
