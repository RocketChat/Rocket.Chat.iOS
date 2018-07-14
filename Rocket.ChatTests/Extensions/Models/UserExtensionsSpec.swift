//
//  UserExtensionsSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 12/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import XCTest

@testable import Rocket_Chat

class UserExtensionsSpec: XCTestCase, RealmTestCase {
    func testSearchUsernameContaining() {
        let realm = testRealm()
        AuthSettingsManager.settings?.useUserRealName = false

        (0..<10).forEach {
            let user = User.testInstance()
            user.identifier = "test_\($0)"
            user.username = user.identifier
            try? realm.write {
                realm.add(user)
            }
        }

        (0..<3).forEach {
            let user = User.testInstance()
            user.identifier = "testpreference_\($0)"
            user.username = user.identifier
            try? realm.write {
                realm.add(user)
            }
        }

        var users = User.search(usernameContaining: "test_", preference: [], limit: 5, realm: realm)
        XCTAssertEqual(users.count, 5)

        users = User.search(usernameContaining: "test_", preference: [], limit: 20, realm: realm)
        XCTAssertEqual(users.count, 10)

        users = User.search(usernameContaining: "_", preference: ["testpreference_1", "testpreference_2"], limit: 2, realm: realm)
        XCTAssertTrue(users.contains(where: { $0.0 == "testpreference_1" }))
        XCTAssertTrue(users.contains(where: { $0.0 == "testpreference_2" }))
    }
}
