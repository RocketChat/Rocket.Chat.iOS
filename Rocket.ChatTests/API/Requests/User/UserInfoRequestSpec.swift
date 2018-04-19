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

class UserInfoRequestSpec: APITestCase {
    func testRequestWithUserId() {
        let preRequest = UserInfoRequest(userId: "nSYqWzZ4GsKTX4dyK")

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        let url = api.host.appendingPathComponent(preRequest.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = "userId=nSYqWzZ4GsKTX4dyK"

        XCTAssertEqual(request.url, urlComponents?.url, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testRequestWithUsername() {
        let preRequest = UserInfoRequest(username: "example")

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        let url = api.host.appendingPathComponent(preRequest.path)
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

        let result = UserInfoResource(raw: json)

        XCTAssertEqual(result.user?.identifier, "nSYqWzZ4GsKTX4dyK", "id is correct")
    }
}
