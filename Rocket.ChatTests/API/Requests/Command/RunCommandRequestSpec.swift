//
//  RunCommandRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class RunCommandRequestSpec: APITestCase {
    func testRequest() {
        let preRequest = RunCommandRequest(command: "command", params: "params", roomId: "roomId")

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is valid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/commands.run", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["command"].string, "command", "command is correct")
        XCTAssertEqual(bodyJson["params"].string, "params", "params is correct")
        XCTAssertEqual(bodyJson["roomId"].string, "roomId", "roomId is correct")
    }
}
