//
//  SearchMessagesRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 25/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SearchMessagesRequestSpec: APISpec {

    func testRequest() {
        let preRequest = SearchMessagesRequest(roomId: "xyz123", searchText: "H")
        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        var components = URLComponents(url: api.host, resolvingAgainstBaseURL: false)
        components?.path = preRequest.path
        components?.query = preRequest.query

        let expectedURL = components?.url

        XCTAssertEqual(preRequest.path, "/api/v1/chat.search", "request path is correct")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString =
        """
        {
            "messages": [
                {
                    "_id": "px9KLW9G2SfD5DKFt",
                    "rid": "GENERAL",
                    "msg": "this is a test",
                    "ts": "2018-03-27T14:44:00.549Z",
                    "u": {
                        "_id": "RtMDEYc28fQ5aHpf4",
                        "username": "marcos.defendi",
                        "name": "Marcos Defendi"
                    },
                    "mentions": [],
                    "channels": [],
                    "_updatedAt": "2018-03-27T14:44:00.550Z",
                    "score": 0.5833333333333334
                }
            ],
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = SearchMessagesResource(raw: json)
        XCTAssertNotNil(result.messages)
        XCTAssertTrue(result.success)

        let nilResult = SearchMessagesResource(raw: nil)
        XCTAssertNil(nilResult.messages)
    }

}
