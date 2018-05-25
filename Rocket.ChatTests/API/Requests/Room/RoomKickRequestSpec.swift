//
//  RoomKickRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 5/18/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class RoomKickRequestSpec: APITestCase {
    func testRequest() {
        let preRequest = RoomKickRequest(roomId: "roomId", roomType: .channel, userId: "userId")

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/channels.kick", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["roomId"].string, "roomId", "roomId is correct")
        XCTAssertEqual(bodyJson["userId"].string, "userId", "userId is correct")
    }

    func testResult() {
        let mockResult = JSON([
            "channel": [
                "_id": "ByehQjC44FwMeiLbX",
                "name": "invite-me",
                "t": "c",
                "usernames": [
                "testing1"
                ],
                "msgs": 0,
                "u": [
                    "_id": "aobEdbYhXfu5hkeqG",
                    "username": "testing1"
                ],
                "ts": "2016-12-09T15:08:58.042Z",
                "ro": false,
                "sysMes": true,
                "_updatedAt": "2016-12-09T15:22:40.656Z"
            ],
            "success": true
        ])

        let result = RoomKickResource(raw: mockResult)

        XCTAssert(result.success == true)

        let nilResult = RoomKickResource(raw: nil)
        XCTAssertNil(nilResult.success, "success is nil if raw is nil")
    }
}
