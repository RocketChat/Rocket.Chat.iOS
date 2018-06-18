//
//  ReadReceiptsRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 6/13/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class ReadReceiptsRequestSpec: APISpec {

    func testRequest() {
        let preRequest = ReadReceiptsRequest(messageId: "message-id")
        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        var components = URLComponents(url: api.host, resolvingAgainstBaseURL: false)
        components?.path = preRequest.path
        components?.query = preRequest.query

        let expectedURL = components?.url

        XCTAssertEqual(preRequest.path, "/api/v1/chat.getMessageReadReceipts", "request path is correct")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.url?.query, "messageId=message-id", "query is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString =
        """
        {
            "receipts": [
                {
                    "user": {
                        "username": "matheus.cardoso"
                    }
                },
                {
                    "user": {
                        "username": "rafael.kellermann"
                    }
                },
                {
                    "user": {
                        "username": "filipe.alvarenga"
                    }
                }
            ],
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = ReadReceiptsResource(raw: json)
        XCTAssertEqual(result.users.count, 3)

        let nilResult = SearchMessagesResource(raw: nil)
        XCTAssertNil(nilResult.messages)
    }

}
