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
    func testRequestNotNil() {
        let request = LoginRequest("username", "password")
        XCTAssertNotNil(request.request(for: API.shared), "request is not nil")
    }

    func testRequestNil() {
        let request = LoginRequest("username", "password")
        XCTAssertNil(request.request(for: API(host: "malformed host")), "request is nil")
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
