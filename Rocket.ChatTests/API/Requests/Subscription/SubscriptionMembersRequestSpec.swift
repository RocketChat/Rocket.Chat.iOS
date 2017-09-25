//
//  SubscriptionMembersRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 9/21/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SubscriptionMembersRequestSpec: XCTestCase {
    func testRequestWithRoomId() {
        let _request = SubscriptionMembersRequest(roomId: "ByehQjC44FwMeiLbX")
        guard let request = _request.request(for: API.shared, options: .paginated(count: 20, offset: 100)) else {
            return XCTFail("request is not nil")
        }
        let url = API.shared.host.appendingPathComponent(_request.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = "roomId=ByehQjC44FwMeiLbX&count=20&offset=100"

        XCTAssertEqual(request.url, urlComponents?.url, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testRequestWithRoomName() {
        let _request = SubscriptionMembersRequest(roomName: "testing")
        guard let request = _request.request(for: API.shared, options: .paginated(count: 20, offset: 100)) else {
            return XCTFail("request is not nil")
        }
        let url = API.shared.host.appendingPathComponent(_request.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = "roomName=testing&count=20&offset=100"

        XCTAssertEqual(request.url, urlComponents?.url, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString = """
        {
            "members": [
                {
                    "_id": "ByehQjC44FwMeiLbX",
                    "status": "online",
                    "name": "Testing One",
                    "utcOffset": 5,
                    "username": "testing1"
                },
                {
                    "_id": "ByehQjC44FwMeiLbX",
                    "status": "online",
                    "name": "Testing One",
                    "utcOffset": 5,
                    "username": "testing1"
                }
            ],
            "count": 2,
            "offset": 10,
            "total": 12,
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = SubscriptionMembersResult(raw: json)

        XCTAssertEqual(result.members?.count, json["members"].count, "members is correct")
        XCTAssertEqual(result.count, 2, "count is correct")
        XCTAssertEqual(result.offset, 10, "offset is correct")
        XCTAssertEqual(result.total, 12, "total is correct")
    }
}
