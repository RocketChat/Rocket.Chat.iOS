//
//  CommandsClientSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class CommandsClientSpec: XCTestCase, RealmTestCase {
    func testFetchCommands() {
        let api = MockAPI()
        let realm = testRealm()
        let client = CommandsClient(api: api)

        api.nextResult = JSON([
            "commands": [
                [
                    "command": "gimme",
                    "clientOnly": false
                ],
                [
                    "command": "kick",
                    "clientOnly": false
                ]
            ]
        ])

        client.fetchCommands(realm: realm)

        XCTAssertEqual(realm.objects(Command.self).count, 2)
    }
}
