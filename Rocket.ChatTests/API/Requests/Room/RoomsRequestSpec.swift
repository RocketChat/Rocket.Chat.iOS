//
//  RoomsRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 5/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class RoomsRequestSpec: APITestCase {
    func testRequest() {
        let roomsRequest = RoomsRequest()

        guard let request = roomsRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/rooms.get", "path is correct")
        XCTAssertNil(request.url?.query, "has no query parameters")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
    }

    func testRequestWithUpdatedSince() {
        let roomsRequest = RoomsRequest()

        guard let request = roomsRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/rooms.get", "path is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
    }

    func testResource() {
        let rawResource = JSON([
            "update": [
                [
                    "_id": "GENERAL",
                    "name": "general",
                    "t": "c",
                    "_updatedAt": "2018-01-21T21:03:43.736Z",
                    "default": true
                ],
                [
                    "_id": "3WpJQkDHhrWPBvXuWhw5DThnhQmxDWnavu",
                    "t": "d",
                    "_updatedAt": "2018-01-21T21:07:16.123Z"
                ],
                [
                    "_id": "hw5DThnhQmxDWnavurocket.cat",
                    "t": "d",
                    "_updatedAt": "2018-01-21T21:07:18.510Z"
                ]
            ],
            "remove": [
                [
                    "_id": "hw5DThnhQmxDWnavuhw5DThnhQmxDWnavu",
                    "t": "d",
                    "_updatedAt": "2018-01-21T21:07:20.324Z"
                ],
                [
                    "_id": "EAemRsye7khfr9Stt",
                    "name": "123",
                    "fname": "123",
                    "t": "p",
                    "_updatedAt": "2018-01-24T21:02:04.318Z",
                    "customFields": {},
                    "ro": false
                ]
            ],
            "success": true
        ])

        let resource = RoomsResource(raw: rawResource)
        XCTAssert(resource.success == true)
        XCTAssert(resource.remove?.count == 2)
        XCTAssert(resource.update?.count == 3)
        XCTAssert(resource.list == nil)
    }

    func testListResource() {
        let rawResource = JSON([
            "result": [
                [
                    "_id": "hw5DThnhQmxDWnavuhw5DThnhQmxDWnavu",
                    "t": "d",
                    "_updatedAt": "2018-01-21T21:07:20.324Z"
                ],
                [
                    "_id": "EAemRsye7khfr9Stt",
                    "name": "123",
                    "fname": "123",
                    "t": "p",
                    "_updatedAt": "2018-01-24T21:02:04.318Z",
                    "customFields": {},
                    "ro": false
                ]
            ],
            "success": true
        ])

        let resource = RoomsResource(raw: rawResource)
        XCTAssert(resource.success == true)
        XCTAssert(resource.remove == nil)
        XCTAssert(resource.update == nil)
        XCTAssert(resource.list?.count == 2)
    }

    func testNilResource() {
        let nilResource = RoomsResource(raw: nil)
        XCTAssertNil(nilResource.success, "success is nil if raw is nil")
    }
}
