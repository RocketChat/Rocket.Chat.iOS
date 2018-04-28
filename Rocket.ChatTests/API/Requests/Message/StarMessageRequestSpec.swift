//
//  StarMessageRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 4/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class StarMessageRequestSpec: APITestCase {
    func testRequest() {
        let starRequest = StarMessageRequest(msgId: "msgId", star: true)

        guard let request = starRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/chat.starMessage", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["messageId"].string, "msgId", "messageId is correct")
    }

    func testRequestFalse() {
        let starRequest = StarMessageRequest(msgId: "msgId", star: false)

        guard let request = starRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/chat.unStarMessage", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["messageId"].string, "msgId", "messageId is correct")
    }

    func testResult() {
        let rawResult = JSON([
            "success": true
            ])

        let result = StarMessageResource(raw: rawResult)
        XCTAssert(result.success == true)

        let nilResult = StarMessageResource(raw: nil)
        XCTAssertNil(nilResult.success, "success is nil if raw is nil")
    }
}
