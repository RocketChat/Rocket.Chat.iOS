//
//  MeRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 9/26/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class MeRequestSpec: APITestCase {
    func testRequest() {
        let preRequest = MeRequest()
        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        let expectedURL = api.host.appendingPathComponent(preRequest.path)

        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString = """
        {
            "_id": "aobEdbYhXfu5hkeqG",
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
            "active": true,
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = MeResource(raw: json)
        XCTAssertEqual(result.user?.identifier, "aobEdbYhXfu5hkeqG")

        let nilResult = MeResource(raw: nil)
        XCTAssertEqual(nilResult.user, nil)
    }
}
