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

class LoginRequestSpec: XCTestCase {
    func testRequest() {
        let request1 = LoginRequest("testUsername", "testPassword").request(for: API.shared)
        let expectedURL = API.shared.host.appendingPathComponent(LoginRequest.path)

        XCTAssertEqual(request1.url, expectedURL, "url is correct")
        XCTAssertEqual(request1.httpMethod, "POST", "http method is correct")

        guard let body = request1.httpBody else { return XCTFail("body exists") }
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

        let result = LoginResult(raw: json)

        XCTAssertEqual(result.data, json["data"])
        XCTAssertEqual(result.authToken, "9HqLlyZOugoStsXCUfD_0YdwnNnunAJF8V47U3QHXSq")
        XCTAssertEqual(result.userId, "aobEdbYhXfu5hkeqG")
    }
}
