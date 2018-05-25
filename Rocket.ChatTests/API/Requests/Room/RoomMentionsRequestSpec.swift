//
//  RoomMentionsRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 03/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class RoomMentionsRequestSpec: APISpec {

    func testRequest() {
        let preRequest = RoomMentionsRequest(roomId: "xyz123")
        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        var components = URLComponents(url: api.host, resolvingAgainstBaseURL: false)
        components?.path = preRequest.path
        components?.query = preRequest.query

        let expectedURL = components?.url

        XCTAssertEqual(preRequest.path, "/api/v1/channels.getAllUserMentionsByChannel", "request path is correct")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    //swiftlint:disable function_body_length
    func testProperties() {
        let jsonString = """
            {
            "mentions": [
                {
                    "_id": "Gptx3mc6TjSv5tLWb",
                    "rid": "GENERAL",
                    "msg": "@rocket.cat",
                    "ts": "2018-03-12T14:59:14.166Z",
                    "u": {
                        "_id": "47cRd58HnWwpqxhaZ",
                        "username": "test",
                        "name": "test"
                    },
                    "mentions": [
                        {
                            "_id": "47cRd58HnWwpqxhaZ",
                            "username": "rocket.cat"
                        }
                    ],
                    "channels": [],
                    "_updatedAt": "2018-03-12T14:59:14.171Z"
                },
                {
                    "_id": "rwerwfjuii6TjSv5tLWb",
                    "rid": "GENERAL",
                    "msg": "@rocket.cat",
                    "ts": "2018-03-12T14:59:14.166Z",
                    "u": {
                        "_id": "47cRd58HnWwpqxhaZ",
                        "username": "test",
                        "name": "test"
                    },
                    "mentions": [
                        {
                            "_id": "47cRd58HnWwpqxhaZ",
                            "username": "rocket.cat"
                        }
                    ],
                    "channels": [],
                    "_updatedAt": "2018-03-12T14:59:14.171Z"
                }
            ],
        "count": 2,
        "offset": 10,
        "total": 2,
        "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = RoomMentionsResource(raw: json)
        XCTAssertNotNil(result.messages)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.offset, 10)
        XCTAssertEqual(result.total, 2)
        XCTAssertTrue(result.success)

        let nilResult = RoomMentionsResource(raw: nil)
        XCTAssertNil(nilResult.messages)
    }

}
