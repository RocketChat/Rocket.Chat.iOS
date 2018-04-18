//
//  UpdateUserRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 06/03/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class UpdateUserRequestSpec: APITestCase {

    func testRequest() {
        let password = "123456"
        let currentPassword = "654321"
        let user = User()
        user.name = "Example User"
        user.username = "example"
        user.emails.append(Email(value: ["email": "example@example.com", "verified": true]))

        let preRequest = UpdateUserRequest(user: user, password: password, currentPassword: currentPassword)

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/users.updateOwnBasicInfo", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["data"]["name"].string, user.name, "name is correct")
        XCTAssertEqual(bodyJson["data"]["username"].string, user.username, "username is correct")
        XCTAssertEqual(bodyJson["data"]["email"].string, user.emails.first?.email, "email is correct")
        XCTAssertEqual(bodyJson["data"]["newPassword"].string, password, "password is correct")
        XCTAssertEqual(bodyJson["data"]["currentPassword"].string, currentPassword.sha256(), "current password is correct")
    }

    func testResult() {
        let jsonString = """
        {
            "user": {
                "_id": "3TmCqTLBqFL4QLNPu",
                "name": "Example User",
                "emails": [
                    {
                        "address": "example@example.com",
                        "verified": true
                    }
                ],
                "status": "offline",
                "statusConnection": "offline",
                "username": "example",
                "utcOffset": 0,
                "active": true
            },
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = UpdateUserResource(raw: json)
        XCTAssertEqual(result.user?.identifier, "3TmCqTLBqFL4QLNPu")

        XCTAssertTrue(result.success)

        let nilResult = UpdateUserResource(raw: nil)
        XCTAssertEqual(nilResult.user, nil)
    }

}
