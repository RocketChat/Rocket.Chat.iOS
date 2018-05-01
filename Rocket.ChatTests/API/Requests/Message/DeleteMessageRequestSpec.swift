//
//  DeleteMessageRequest.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 1/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class DeleteMessageRequestSpec: APITestCase {
    func testRequest() {
        let preRequest = DeleteMessageRequest(roomId: "roomId", msgId: "msgId", asUser: false)

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/chat.delete", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["roomId"].string, "roomId", "roomId is correct")
        XCTAssertEqual(bodyJson["msgId"].string, "msgId", "roomId is correct")
    }

    func testResult() {
        let mockResult = JSON([
            "_id": "i68rmSm0Tslr4S4DMu",
            "message": [
                "rid": "pcHSHHjvJLBcud3dh",
                "u": [
                "name": "Matheus Cardoso",
                "username": "matheus.cardoso",
                "_id": "ERoZg2xpgcDnXbCJu"
                ],
                "_id": "i68rmSm0Tslr4S4DMu"
            ],
            "ts": 1515706859,
            "success": true
        ])

        let result = DeleteMessageResource(raw: mockResult)

        XCTAssert(result.success == true)

        let nilResult = DeleteMessageResource(raw: nil)
        XCTAssertNil(nilResult.success, "success is nil if raw is nil")
    }
}
