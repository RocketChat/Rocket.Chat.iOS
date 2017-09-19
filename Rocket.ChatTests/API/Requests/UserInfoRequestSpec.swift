//
//  UserInfoRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class UserInfoRequestSpec: XCTestCase {
    func testRequestNotNil() {
        let request1 = UserInfoRequest(userId: "nSYqWzZ4GsKTX4dyK")
        XCTAssertNotNil(request1.request(for: API.shared), "request is not nil")

        let request2 = UserInfoRequest(username: "example")
        XCTAssertNotNil(request2.request(for: API.shared), "request is not nil")
    }

    func testRequestNil() {
        let request = UserInfoRequest(userId: "nSYqWzZ4GsKTX4dyK")
        XCTAssertNil(request.request(for: API(host: "malformed host")), "request is nil")
    }

    func testProperties() {
        let jsonString = """
        {
            "user": {
                "_id": "nSYqWzZ4GsKTX4dyK",
                "type": "user",
                "status": "offline",
                "active": true,
                "name": "Example User",
                "utcOffset": 0,
                "username": "example"
            },
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = UserInfoResult(raw: json)

        XCTAssertEqual(result.user, json["user"], "user is correct")
        XCTAssertEqual(result.id, "nSYqWzZ4GsKTX4dyK", "id is correct")
        XCTAssertEqual(result.type, "user", "type is correct")
        XCTAssertEqual(result.name, "Example User", "name is correct")
        XCTAssertEqual(result.username, "example", "username is correct")
    }
}

