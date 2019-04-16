//
//  ThreadFollowRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 16/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class ThreadFollowRequestSpec: APITestCase {
    func testRequestWithMessageId() {
        let preRequest = ThreadFollowRequest(mid: "ByehQjC44FwMeiLbX")

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }

        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is invalid json")
        }

        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.url?.path, "/api/v1/chat.followMessage", "path is correct")
        XCTAssertEqual(bodyJson["mid"], "ByehQjC44FwMeiLbX")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
    }

    func testProperties() {
        XCTFail("request needs to be updated")

        let jsonString = """
        {
            "channel": {
                "_id": "ByehQjC44FwMeiLbX",
                "ts": "2016-11-30T21:23:04.737Z",
                "t": "c",
                "name": "testing",
                "usernames": [
                      "testing",
                      "testing1",
                      "testing2"
                ],
                "msgs": 1,
                "default": true,
                "_updatedAt": "2016-12-09T12:50:51.575Z",
                "lm": "2016-12-09T12:50:51.555Z"
            },
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = RoomInfoResource(raw: json)

        XCTAssertEqual(result.channel, json["channel"])
        XCTAssertEqual(result.usernames ?? [], ["testing", "testing1", "testing2"])
    }
}
