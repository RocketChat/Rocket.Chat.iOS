//
//  ReactMessageRequest.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 1/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class ReactMessageRequestSpec: APITestCase {
    func testRequest() {
        let reactRequest = ReactMessageRequest(msgId: "msgId", emoji: "party_parrot")

        guard let request = reactRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/chat.react", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["messageId"].string, "msgId", "messageId is correct")
        XCTAssertEqual(bodyJson["emoji"].string, "party_parrot", "emoji is correct")
    }

    func testResult() {
        let rawResult = JSON([
            "success": true
        ])

        let result = ReactMessageResource(raw: rawResult)
        XCTAssert(result.success == true)

        let nilResult = ReactMessageResource(raw: nil)
        XCTAssertNil(nilResult.success, "success is nil if raw is nil")
    }
}
