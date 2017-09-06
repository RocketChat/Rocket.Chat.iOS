//
//  DatabaseManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 06/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class DatabaseManagerSpec: XCTestCase {

    func testSelectedIndex() {
        UserDefaults.standard.set(0, forKey: ServerPersistKeys.selectedIndex)
        XCTAssertEqual(DatabaseManager.selectedIndex, 0, "selectedIndex is correct")
    }

    func testSelectedIndexEmpty() {
        UserDefaults.standard.removeObject(forKey: ServerPersistKeys.selectedIndex)
        XCTAssertEqual(DatabaseManager.selectedIndex, 0, "selectedIndex returns 0 when value is nil")
    }

}
