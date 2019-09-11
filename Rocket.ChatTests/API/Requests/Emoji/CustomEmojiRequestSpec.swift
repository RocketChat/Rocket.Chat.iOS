//
//  CustomEmojiRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 02/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class CustomEmojiRequestSpec: APITestCase {

    func testRequest() {
        let preRequest = CustomEmojiRequest()
        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        let expectedURL = api.host.appendingPathComponent(preRequest.path)

        XCTAssertEqual(preRequest.path, "/api/v1/emoji-custom.list", "url subpath is correct")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString = """
        {
        "emojis": {
            "update": [
                {
                    "_id": "S5XvYppoLrLd9JvQm",
                    "name": "teste",
                    "aliases": [],
                    "extension": "jpg",
                    "_updatedAt": "2019-02-18T16:48:35.119Z"
                },
                {
                    "_id": "Ro5HD4wKQiYnrbpbg",
                    "name": "aaaaaaaa",
                    "aliases": [
                        "aaaaaa"
                    ],
                    "extension": "png",
                    "_updatedAt": "2019-02-18T16:49:47.310Z"
                }
            ],
            "remove": []
            },
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = CustomEmojiResource(raw: json)
        XCTAssertEqual(result.customEmoji.count, 2)
        XCTAssertEqual(result.success, true)

        let nilResult = CustomEmojiResource(raw: nil)
        XCTAssertEqual(nilResult.customEmoji.count, 0)
        XCTAssertEqual(nilResult.success, false)
    }

}
