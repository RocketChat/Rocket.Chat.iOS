//
//  UsersListRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 25.11.2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class UsersListRequestSpec: APITestCase {
    func testRequestForName() {
        let _request = UsersListRequest(name: "example")
        guard let request = _request.request(for: api) else {
            return XCTFail("request is not nil")
        }

        let url = api.host.appendingPathComponent(_request.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = "query={ \"username\": { \"$regex\": \"example\" } }"

        XCTAssertEqual(request.url, urlComponents?.url, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString = """
        {
          "users": [
            {
              "_id": "nSYqWzZ4GsKTX4dyK",
              "type": "user",
              "status": "offline",
              "active": true,
              "name": "Example User",
              "utcOffset": 0,
              "username": "example"
            }
          ],
          "count": 10,
          "offset": 0,
          "total": 10,
          "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = UsersListResult(raw: json)

        XCTAssertEqual(result.users?.count, 1, "users count is incorrect")
        XCTAssertEqual(result.count, 10, "count is incorrect")
        XCTAssertEqual(result.offset, 0, "offset is incorrect")
        XCTAssertEqual(result.total, 10, "total is incorrect")

        // No need to test User here, there is another test for that
    }
}
