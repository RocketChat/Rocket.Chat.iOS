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
        guard let request = UserInfoRequest(userId: "nSYqWzZ4GsKTX4dyK").request(for: API.shared) else {
            return XCTFail("request is not nil")
        }
        let url = API.shared.host.appendingPathComponent(UserInfoRequest.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = "userId=nSYqWzZ4GsKTX4dyK"

        XCTAssertEqual(request.url, urlComponents?.url, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testRequestWithUsername() {
        guard let request = UserInfoRequest(username: "example").request(for: API.shared) else {
            return XCTFail("request is not nil")
        }
        let url = API.shared.host.appendingPathComponent(UserInfoRequest.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = "username=example"

        XCTAssertEqual(request.url, urlComponents?.url, "url is correct")
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
