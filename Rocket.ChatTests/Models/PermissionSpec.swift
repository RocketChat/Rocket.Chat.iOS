//
//  PermissionSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

class PermissionSpec: XCTestCase {
    let testJSON = JSON([
        "_id": "snippet-message",
        "roles": [
            "owner",
            "moderator",
            "admin"
        ],
        "_updatedAt": [ "$date": 1480377601 ],
        "meta": [
            "revision": 3,
            "created": 1480377601,
            "version": 0,
            "updated": 1480377601
        ],
        "$loki": 1
    ])

    func testMap() {
        let permission = Rocket_Chat.Permission()
        permission.map(testJSON, realm: nil)

        XCTAssertTrue(permission.roles.contains("owner"), "has owner role")
        XCTAssertTrue(permission.roles.contains("moderator"), "has moderator role")
        XCTAssertTrue(permission.roles.contains("admin"), "has admin role")
    }
}
