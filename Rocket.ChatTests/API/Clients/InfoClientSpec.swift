//
//  InfoClientSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class InfoClientSpec: XCTestCase, RealmTestCase {
    func testFetchInfo() {
        let api = MockAPI()
        let realm = testRealm()
        let client = InfoClient(api: api)

        api.nextResult = JSON([
            "info": [
                "version": "0.59.3"
            ],
            "success": "true"
        ])

        try? realm.write {
            realm.add(Auth.testInstance())
        }

        client.fetchInfo(realm: realm)

        let expectation = XCTestExpectation(description: "correct info added to realm")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            if AuthManager.isAuthenticated(realm: realm)?.serverVersion == "0.59.3" {
                expectation.fulfill()
            }
        })
        wait(for: [expectation], timeout: 1.1)
    }
}
