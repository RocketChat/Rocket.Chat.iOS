//
//  RoomInviteRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 5/21/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class RoomInviteRequestSpec: APITestCase {
    func testRequest() {
        let preRequest = RoomInviteRequest(roomId: "roomId", roomType: .channel, userId: "userId")

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/channels.invite", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["roomId"].string, "roomId", "roomId is correct")
        XCTAssertEqual(bodyJson["userId"].string, "userId", "userId is correct")
    }

    func testResult() {
        let mockResult = JSON([
            "channel": [
                "_id": "ByehQjC44FwMeiLbX",
                "ts": "2016-11-30T21:23:04.737Z",
                "t": "c",
                "name": "testing",
                "usernames": [
                "testing",
                "testing1"
                ],
                "u": [
                    "_id": "aobEdbYhXfu5hkeqG",
                    "username": "testing1"
                ],
                "msgs": 1,
                "_updatedAt": "2016-12-09T12:50:51.575Z",
                "lm": "2016-12-09T12:50:51.555Z"
            ],
            "success": true
        ])

        let result = RoomInviteResource(raw: mockResult)

        XCTAssert(result.success == true)

        let nilResult = RoomInviteResource(raw: nil)
        XCTAssertNil(nilResult.success, "success is nil if raw is nil")
    }
}
