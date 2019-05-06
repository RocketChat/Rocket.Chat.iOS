//
//  ThreadMessagesRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 16/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class ThreadMessagesRequestSpec: APITestCase {
    func testRequestWithThreadId() {
        let preRequest = ThreadMessagesRequest(tmid: "ByehQjC44FwMeiLbX")

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.url?.path, "/api/v1/chat.getThreadMessages", "path is correct")
        XCTAssertEqual(request.url?.query, "tmid=ByehQjC44FwMeiLbX")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
    }

    func testProperties() {
        let jsonString = """
         {
          "count" : 2,
          "messages" : [{
              "_updatedAt" : "2019-05-03T15:10:17.863Z",
              "tmid" : "OxZ0pgHPOEMZgoiEb6",
              "unread" : true,
              "msg" : "Yay.",
              "rid" : "GENERAL",
              "mentions" : [],
              "_id" : "zBYXi4WsMmWkrLPFuU",
              "ts" : "2019-05-03T15:10:17.841Z",
              "u" : {
                "username" : "rafael.kellermann",
                "name" : "Rafael Kellermann Streit",
                "_id" : "Xx6KW6XQsFkmDPGdE"
              },
              "channels" : []
            }, {
              "_updatedAt" : "2019-05-03T15:10:45.442Z",
              "tmid" : "OxZ0pgHPOEMZgoiEb6",
              "unread" : true,
              "msg" : "Foobar.",
              "rid" : "GENERAL",
              "mentions" : [],
              "_id" : "3VXsUZuCvXQWOpPt2N",
              "ts" : "2019-05-03T15:10:45.417Z",
              "u" : {
                "username" : "rafael.kellermann",
                "name" : "Rafael Kellermann Streit",
                "_id" : "Xx6KW6XQsFkmDPGdE"
              },
              "channels" : []
            }
          ],
          "total" : 2,
          "success" : true,
          "offset" : 0
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = ThreadMessagesResource(raw: json)
        XCTAssertEqual(result.messages.count, 2)
        XCTAssertEqual(result.count, 2)
        XCTAssertEqual(result.total, 2)
        XCTAssertEqual(result.offset, 0)
        XCTAssertTrue(result.success ?? false)
    }
}
