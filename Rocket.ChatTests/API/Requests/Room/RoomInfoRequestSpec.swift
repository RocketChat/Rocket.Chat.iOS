//
//  RoomInfoRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class RoomInfoRequestSpec: APITestCase {
    func testRequestWithRoomId() {
        let preRequest = RoomInfoRequest(roomId: "ByehQjC44FwMeiLbX")
        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        let url = api.host.appendingPathComponent(preRequest.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = "roomId=ByehQjC44FwMeiLbX"

        XCTAssertEqual(request.url, urlComponents?.url, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    func testRequestWithRoomName() {
        let preRequest = RoomInfoRequest(roomName: "testing")
        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }
        let url = api.host.appendingPathComponent(preRequest.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = "roomName=testing"

        XCTAssertEqual(request.url, urlComponents?.url, "url is correct")
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

        let result = RoomInfoResource(raw: json)

        XCTAssertEqual(result.channel, json["channel"])
        XCTAssertEqual(result.usernames ?? [], ["testing", "testing1", "testing2"])
    }
}
