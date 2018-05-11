//
//  PinMessageRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 5/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class PinMessageRequestSpec: APITestCase {
    func testRequest() {
        let pinRequest = PinMessageRequest(msgId: "msgId", pin: true)

        guard let request = pinRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/chat.pinMessage", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["messageId"].string, "msgId", "messageId is correct")
    }

    func testRequestFalse() {
        let pinRequest = PinMessageRequest(msgId: "msgId", pin: false)

        guard let request = pinRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/chat.unPinMessage", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["messageId"].string, "msgId", "messageId is correct")
    }

    func testResult() {
        let rawResult = JSON([
            "success": true
        ])

        let result = PinMessageResource(raw: rawResult)
        XCTAssert(result.success == true)

        let nilResult = PinMessageResource(raw: nil)
        XCTAssertNil(nilResult.success, "success is nil if raw is nil")
    }
}
