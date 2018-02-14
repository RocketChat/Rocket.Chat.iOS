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

        let expectation = XCTestExpectation(description: "two commands added to realm")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
            if realm.objects(Command.self).count == 2 {
                expectation.fulfill()
            }
        })
        wait(for: [expectation], timeout: 1.0)
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
