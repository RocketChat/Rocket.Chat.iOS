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
    func testRequestWithUserId() {
        let request = UserInfoRequest(userId: "nSYqWzZ4GsKTX4dyK").request(for: API.shared)
        let expectedURL = API.shared.host.appendingPathComponent("\(UserInfoRequest.path)?userId=nSYqWzZ4GsKTX4dyK")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testRequestWithUsername() {
        let request = UserInfoRequest(username: "example").request(for: API.shared)
        let expectedURL = API.shared.host.appendingPathComponent("\(UserInfoRequest.path)?username=example")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
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
