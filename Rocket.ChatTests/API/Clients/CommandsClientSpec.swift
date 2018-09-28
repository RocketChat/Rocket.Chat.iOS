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

    func testRunCommand() {
        let api = MockAPI()
        let client = CommandsClient(api: api)

        api.nextResult = JSON([
            "success": true
        ])

        api.nextError = APIError.noData

        client.runCommand(command: "gimme", params: "test", roomId: "general", succeeded: { result in
            XCTAssert(result.success == true)
        }, errored: { error in
            guard case .noData = error else {
                return XCTFail("error is correct")
            }
        })
    }
}
