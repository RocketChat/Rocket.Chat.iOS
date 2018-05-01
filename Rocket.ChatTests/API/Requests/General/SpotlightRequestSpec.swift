//
//  SpotlightRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SpotlightRequestSpec: APITestCase {
    func testRequest() {
        let spotlightRequest = SpotlightRequest(query: "test")
        guard let request = spotlightRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        let url = api.host.appendingPathComponent(spotlightRequest.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = "query=test"

        XCTAssertEqual(request.url, urlComponents?.url, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString = """
        {
          "users": [
            {
              "_id": "rocket.cat",
              "name": "Rocket.Cat",
              "username": "rocket.cat",
              "status": "online"
            },
          ],
          "rooms": ["test", "test2"],
          "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = SpotlightResource(raw: json)

        XCTAssertEqual(result.users.count, 1, "users is correct")
        XCTAssertEqual(result.rooms.count, 2, "rooms is correct")
        XCTAssertEqual(result.success, true, "success is correct")
    }
}
