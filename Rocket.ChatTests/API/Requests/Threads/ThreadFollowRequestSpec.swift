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
        let jsonString = "{ \"success\": true }"
        let json = JSON(parseJSON: jsonString)
        let result = ThreadFollowResource(raw: json)

        XCTAssertTrue(result.success ?? false)
    }
}
