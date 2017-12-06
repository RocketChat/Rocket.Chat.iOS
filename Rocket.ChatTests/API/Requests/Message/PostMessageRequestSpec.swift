//
//  PostMessageRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/14/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class PostMessageRequestSpec: APITestCase {
    func testRequest() {
        let _request = PostMessageRequest(roomId: "roomId", text: "text")

        guard let request = _request.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/chat.postMessage", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["text"].string, "text", "text is correct")
        XCTAssertEqual(bodyJson["roomId"].string, "roomId", "roomId is correct")
    }

    func testResult() {
        let _result = JSON([
            "ts": 148174896,
            "channel": "general",
            "message": [
                "alias": "",
                "msg": "This is a test!",
                "parseUrls": true,
                "groupable": false,
                "ts": "2016-12-14T20:56:05.117Z",
                "u": [
                    "_id": "y65tAmHs93aDChMWu",
                    "username": "graywolf336"
                ],
                "rid": "GENERAL",
                "_updatedAt": "2016-12-14T20:56:05.119Z",
                "_id": "jC9chsFddTvsbFQG7"
            ],
            "success": true
        ])

        let result = APIResult<PostMessageRequest>(raw: _result)

        let message = Message()
        message.map(_result["message"], realm: nil)

        XCTAssertEqual(result.message?.identifier, "jC9chsFddTvsbFQG7", "message is correct")

        let nilResult = APIResult<PostMessageRequest>(raw: nil)
        XCTAssertNil(nilResult.message, "message is nil if raw is nil")
    }
}
