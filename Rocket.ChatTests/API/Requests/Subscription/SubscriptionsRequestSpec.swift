//
//  SubscriptionsRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 5/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SubscriptionsRequestSpec: APITestCase {
    func testRequest() {
        let subscriptionsRequest = SubscriptionsRequest()

        guard let request = subscriptionsRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/subscriptions.get", "path is correct")
        XCTAssertNil(request.url?.query, "has no query parameters")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
    }

    func testRequestWithUpdatedSince() {
        let subscriptionsRequest = SubscriptionsRequest()

        guard let request = subscriptionsRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/subscriptions.get", "path is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
    }

    func testResource() {
        let rawResource = JSON([
            "remove": [
                [
                    "t": "c",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "general",
                    "fname": nil,
                    "rid": "GENERAL",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "5ALsG3QhpJfdMpyc8"
                ]
            ],
            "update": [
                [
                    "t": "c",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "general",
                    "fname": nil,
                    "rid": "GENERAL",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "5ALsG3QhpJfdMpyc8"
                ],
                [
                    "t": "p",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "important",
                    "fname": nil,
                    "rid": "Ajalkjdaoiqw",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "LKSAJdklasd123"
                ]
            ],
            "success": true
        ])

        let resource = SubscriptionsResource(raw: rawResource)
        XCTAssert(resource.success == true)
        XCTAssert(resource.remove?.count == 1)
        XCTAssert(resource.update?.count == 2)
        XCTAssert(resource.list == nil)
    }

    func testListResource() {
        let rawResource = JSON([
            "result": [
                [
                    "t": "c",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "general",
                    "fname": nil,
                    "rid": "GENERAL",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "5ALsG3QhpJfdMpyc8"
                ],
                [
                    "t": "p",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "important",
                    "fname": nil,
                    "rid": "Ajalkjdaoiqw",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "LKSAJdklasd123"
                ]
            ],
            "success": true
        ])

        let resource = SubscriptionsResource(raw: rawResource)
        XCTAssert(resource.success == true)
        XCTAssert(resource.remove == nil)
        XCTAssert(resource.update == nil)
        XCTAssert(resource.list?.count == 2)
    }

    func testNilResource() {
        let nilResource = SubscriptionsResource(raw: nil)
        XCTAssertNil(nilResource.success, "success is nil if raw is nil")
    }
}
