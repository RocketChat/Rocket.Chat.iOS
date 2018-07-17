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

class RoomCreateRequestSpec: APITestCase {
    func testRequest() {
        let paramRoomName = "foo"
        let paramReadOnly = false
        let paramMembers = ["example"]

        let preRequest = RoomCreateRequest(
            name: paramRoomName,
            type: .channel,
            members: paramMembers,
            readOnly: paramReadOnly
        )

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        guard let httpBody = request.httpBody else {
            return XCTFail("body is not nil")
        }
        guard let bodyJson = try? JSON(data: httpBody) else {
            return XCTFail("body is invalid json")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/channels.create", "path is correct")
        XCTAssertEqual(request.httpMethod, "POST", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertEqual(bodyJson["name"].string, paramRoomName, "parameter read only is correct")
        XCTAssertEqual(bodyJson["members"].array?.first?.string, paramMembers.first, "parameter members is correct")
        XCTAssertEqual(bodyJson["readOnly"].bool, paramReadOnly, "read only was set as false")

        let preRequestGroup = RoomCreateRequest(
            name: paramRoomName,
            type: .group,
            readOnly: paramReadOnly
        )

        guard let requestGroup = preRequestGroup.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertEqual(requestGroup.url?.path, "/api/v1/groups.create", "path is correct")
    }

    func testResult() {
        let mockResult = JSON([
            "channel": [
                "_id": "ByehQjC44FwMeiLbX",
                "name": "channelname",
                "t": "c",
                "usernames": [
                    "example"
                ],
                "msgs": 0,
                "u": [
                    "_id": "aobEdbYhXfu5hkeqG",
                    "username": "example"
                ],
                "ts": "2016-05-30T13:42:25.304Z"
            ],
            "success": true,
            "error": "error-test"
        ])

        let mockResultPrivate = JSON([
            "group": [
                "name": "groupname",
                "t": "p"
            ]
        ])

        let result = RoomCreateResource(raw: mockResult)
        let resultPrivate = RoomCreateResource(raw: mockResultPrivate)

        XCTAssertEqual(result.success, true, "success is correct")
        XCTAssertEqual(result.error, "error-test", "error is correct")
        XCTAssertEqual(result.name, "channelname", "name is correct")
        XCTAssertEqual(resultPrivate.name, "groupname", "name is correct")
    }
}
