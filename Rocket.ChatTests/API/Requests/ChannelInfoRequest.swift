//
//  ChannelInfoRequest.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class ChannelInfoRequestSpec: XCTestCase {
    func testRequestWithRoomId() {
        let request = ChannelInfoRequest(roomId: "ByehQjC44FwMeiLbX").request(for: API.shared)
        let expectedURL = API.shared.host.appendingPathComponent("\(ChannelInfoRequest.path)?roomId=ByehQjC44FwMeiLbX")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testRequestWithRoomName() {
        let request = ChannelInfoRequest(roomName: "testing").request(for: API.shared)
        let expectedURL = API.shared.host.appendingPathComponent("\(ChannelInfoRequest.path)?roomName=testing")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString = """
        {
            "channel": {
                "_id": "ByehQjC44FwMeiLbX",
                "ts": "2016-11-30T21:23:04.737Z",
                "t": "c",
                "name": "testing",
                "usernames": [
                      "testing",
                      "testing1",
                      "testing2"
                ],
                "msgs": 1,
                "default": true,
                "_updatedAt": "2016-12-09T12:50:51.575Z",
                "lm": "2016-12-09T12:50:51.555Z"
            },
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = ChannelInfoResult(raw: json)

        XCTAssertEqual(result.channel, json["channel"])
        XCTAssertEqual(result.usernames ?? [], ["testing", "testing1", "testing2"])
    }
}
