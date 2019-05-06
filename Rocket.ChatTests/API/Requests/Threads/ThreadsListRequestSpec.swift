//
//  ThreadsListRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 16/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class ThreadsListRequestSpec: APITestCase {
    func testRequestWithRoomId() {
        let preRequest = ThreadsListRequest(rid: "ByehQjC44FwMeiLbX")

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.url?.path, "/api/v1/chat.getThreadsList", "path is correct")
        XCTAssertEqual(request.url?.query, "rid=ByehQjC44FwMeiLbX&sort=%7B%22tlm%22:-1%7D")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
    }

    func testProperties() {
        let jsonString = """
        {
          "threads" : [{
            "_updatedAt" : "2019-05-03T15:10:45.793Z",
            "tcount" : 2,
            "tlm" : "2019-05-03T15:10:45.417Z",
            "unread" : true,
            "msg" : "Teste 1",
            "rid" : "GENERAL",
            "mentions" : [],
            "_id" : "OxZ0pgHPOEMZgoiEb6",
            "replies" : [
              "Xx6KW6XQsFkmDPGdE"
            ],
            "ts" : "2019-05-03T15:10:13.003Z",
            "u" : {
              "username" : "rafael.kellermann",
              "name" : "Rafael Kellermann Streit",
              "_id" : "Xx6KW6XQsFkmDPGdE"
            },
            "channels" : []
          }],
          "count" : 1,
          "total" : 1,
          "success" : true,
          "offset" : 0
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = ThreadsListResource(raw: json)
        XCTAssertEqual(result.threads.count, 1)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.total, 1)
        XCTAssertEqual(result.offset, 0)
        XCTAssertTrue(result.success ?? false)
    }
}
