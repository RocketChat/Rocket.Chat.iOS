//
//  WebBrowserManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 23/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class WebBrowserManagerSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        WebBrowserManager.clearDefaultBrowser()
    }

    func testDefaultBrowser() {
        XCTAssertEqual(WebBrowserManager.browser, .inAppSafari)
    }

    func testSettingDefaultBrowser() {
        WebBrowserManager.set(defaultBrowser: .safari)
        XCTAssertEqual(WebBrowserManager.browser, .safari)
    }

}
