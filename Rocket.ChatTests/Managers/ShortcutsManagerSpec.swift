//
//  ShortcutsManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 12.07.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ShortcutsManagerSpec: XCTestCase {

    func testNoShortcutsAvailable() {
        DatabaseManager.clearAllServers()
        ShortcutsManager.sync()

        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 0, "no shortcuts in the list")
    }

    func testShortcutsAvailable() {
        DatabaseManager.setupTestServers()
        ShortcutsManager.sync()

        XCTAssertEqual(UIApplication.shared.shortcutItems?.count, 2, "2 shortcuts in the list")
    }
}
