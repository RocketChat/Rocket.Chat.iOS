//
//  RoomHistoryRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 29/12/2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class RoomHistoryRequestSpec: APITestCase {
    func testRequest() {
        let latestString = "2018-12-29T10:56:15.236Z"
        let latest = Date.dateFromString(latestString)

        let oldestString = "2017-04-14T11:34:12.123Z"
        let oldest = Date.dateFromString(oldestString)

        let preRequest = RoomHistoryRequest(
            roomType: .channel,
            roomId: "roomId",
            latest: latest,
            oldest: oldest,
            inclusive: true,
            count: 10,
            unreads: true
        )

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/channels.history", "path is correct")

        XCTAssertEqual(
            request.url?.query,
            "roomId=roomId&latest=\(latestString)&oldest=\(oldestString)&inclusive=true&count=10&unreads=true",
            "query is correct"
        )

        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
        XCTAssertNil(request.httpBody, "body is nil")
    }

    // swiftlint:disable function_body_length
    func testResult() {
        let mockResult = JSON([
            "messages": [
                [
                    "_id": "AkzpHAvZpdnuchw2a",
                    "rid": "ByehQjC44FwMeiLbX",
                    "msg": "hi",
                    "ts": "2016-12-09T12:50:51.555Z",
                    "u": [
                        "_id": "y65tAmHs93aDChMWu",
                        "username": "testing"
                    ],
                    "_updatedAt": "2016-12-09T12:50:51.562Z"
                ],
                [
                    "_id": "vkLMxcctR4MuTxreF",
                    "t": "uj",
                    "rid": "ByehQjC44FwMeiLbX",
                    "ts": "2016-12-08T15:41:37.730Z",
                    "msg": "testing2",
                    "u": [
                        "_id": "bRtgdhzM6PD9F8pSx",
                        "username": "testing2"
                    ],
                    "groupable": false,
                    "_updatedAt": "2016-12-08T16:03:25.235Z"
                ],
                [
                    "_id": "bfRW658nEyEBg75rc",
                    "t": "uj",
                    "rid": "ByehQjC44FwMeiLbX",
                    "ts": "2016-12-07T15:47:49.099Z",
                    "msg": "testing",
                    "u": [
                        "_id": "nSYqWzZ4GsKTX4dyK",
                        "username": "testing1"
                    ],
                    "groupable": false,
                    "_updatedAt": "2016-12-07T15:47:49.099Z"
                ],
                [
                    "_id": "pbuFiGadhRZTKouhB",
                    "t": "uj",
                    "rid": "ByehQjC44FwMeiLbX",
                    "ts": "2016-12-06T17:57:38.635Z",
                    "msg": "testing",
                    "u": [
                        "_id": "y65tAmHs93aDChMWu",
                        "username": "testing"
                    ],
                    "groupable": false,
                    "_updatedAt": "2016-12-06T17:57:38.635Z"
                ]
            ],
            "success": true
        ])

        let result = RoomInviteResource(raw: mockResult)

        XCTAssert(result.success == true)

        let nilResult = RoomInviteResource(raw: nil)
        XCTAssertNil(nilResult.success, "success is nil if raw is nil")
    }
}
