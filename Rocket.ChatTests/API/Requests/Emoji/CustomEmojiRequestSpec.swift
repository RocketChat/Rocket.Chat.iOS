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

        XCTAssertEqual(preRequest.path, "/api/v1/emoji-custom", "url subpath is correct")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString = """
        {
            "emojis": [{
                "_id": "yh3dxDWrJy3J6oMMN",
                "name": "test",
                "aliases": [],
                "extension": "jpg",
                "_updatedAt": "2018-02-07T14:58:17.319Z"
            }],
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = CustomEmojiResource(raw: json)
        XCTAssertEqual(result.customEmoji.count, 1)
        XCTAssertEqual(result.success, true)

        let nilResult = CustomEmojiResource(raw: nil)
        XCTAssertEqual(nilResult.customEmoji.count, 0)
        XCTAssertEqual(nilResult.success, false)
    }

}
