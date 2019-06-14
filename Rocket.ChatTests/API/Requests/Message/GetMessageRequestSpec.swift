//
//  GetMessageRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 10/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class GetMessagesRequestSpec: APISpec {

    func testRequest() {
        let preRequest = GetMessageRequest(msgId: "123")
        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        var components = URLComponents(url: api.host, resolvingAgainstBaseURL: false)
        components?.path = preRequest.path
        components?.query = preRequest.query

        let expectedURL = components?.url

        XCTAssertEqual(preRequest.path, "/api/v1/chat.getMessage", "request path is correct")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString =
        """
        {
            "message": {
                "_updatedAt": "2019-04-08T15:58:58.659Z",
                "_id": "wbkmpjcdZdijXQW63",
                "attachments": [],
                "replies": [
                    "SoE3FdtRxxtBcPtdW"
                ],
                "mentions": [

                ],
                "u": {
                    "username": "thiago.sanchez",
                    "_id": "SoE3FdtRxxtBcPtdW",
                    "name": "Thiago Sanchez"
                },
                "ts": "2019-04-05T17:46:10.036Z",
                "tcount": 1,
                "channels": [

                ],
                "rid": "ZXNJtuTvqPLewLfNw",
                "tlm": "2019-04-08T15:58:58.377Z",
                "groupable": false,
                "file": {
                    "_id": "dvTwj5hK7XzkX3ruy",
                    "type": "image/gif",
                    "name": "ToolBar.gif"
                },
                "msg": ""
            },
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = GetMessageResource(raw: json)
        XCTAssertNotNil(result.message)
        XCTAssertTrue(result.success)

        let nilResult = GetMessageResource(raw: nil)
        XCTAssertNil(nilResult.message)
    }

}

