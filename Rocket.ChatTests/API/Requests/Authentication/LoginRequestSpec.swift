//
//  LoginRequest.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class LoginRequestSpec: APITestCase {
    func testRequest() {
        let preRequest = LoginRequest(params: ["username": "testUsername", "password": "testPassword"])
        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        let expectedURL = api.host.appendingPathComponent(preRequest.path)

        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")

        guard let body = request.httpBody else { return XCTFail("body exists") }
        guard let json = try? JSON(data: body) else { return XCTFail("body is json") }

        let expectedJSON = JSON(parseJSON:
            """
            {"username":"testUsername","password":"testPassword"}
            """
        )

        XCTAssertEqual(json, expectedJSON, "body is correct")
    }

    func testProperties() {
        let jsonString = """
        {
            "status": "success",
            "data": {
                "authToken": "9HqLlyZOugoStsXCUfD_0YdwnNnunAJF8V47U3QHXSq",
                "userId": "aobEdbYhXfu5hkeqG"
            }
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = LoginResource(raw: json)

        XCTAssertEqual(result.data, json["data"])
        XCTAssertEqual(result.authToken, "9HqLlyZOugoStsXCUfD_0YdwnNnunAJF8V47U3QHXSq")
        XCTAssertEqual(result.userId, "aobEdbYhXfu5hkeqG")
    }
}
