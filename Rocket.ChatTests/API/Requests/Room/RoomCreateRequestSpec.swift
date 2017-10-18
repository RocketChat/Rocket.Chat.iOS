//
//  RoomCreateRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Bruno Macabeus Aquino on 15/10/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class RoomCreateRequestSpec: XCTestCase {
    func testRequestCreateChannel() {
        let paramRoomName = "foo"
        let paramReadOnly = false

        let _request = RoomCreateRequest(
            roomName: paramRoomName,
            type: .channel,
            readOnly: paramReadOnly
        )

        guard let request = _request.request(for: API.shared) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is invalid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/channels.create", "url is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["name"].string, paramRoomName, "parameter read only is correct")
        XCTAssertEqual(bodyJson["readOnly"].bool, paramReadOnly, "read only was set as false")
    }
}
