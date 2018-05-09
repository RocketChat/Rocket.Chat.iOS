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
        XCTAssertNil(request.url?.query)
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
    }

    func testRequestWithUpdatedSince() {
        guard let date = Date.dateFromString("2015-03-25T12:00:00.000-0300") else {
            return XCTFail("date is not nil")
        }

        let subscriptionsRequest = SubscriptionsRequest(updatedSince: date)

        guard let request = subscriptionsRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/subscriptions.get", "path is correct")
        XCTAssertEqual(request.url?.query, "updatedSince=2015-03-25T12:00:00.000-0300")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
    }

    func testResult() {
        let rawResult = JSON([
            "success": true
        ])

        let result = SubscriptionsResource(raw: rawResult)
        XCTAssert(result.success == true)

        let nilResult = SubscriptionsResource(raw: nil)
        XCTAssertNil(nilResult.success, "success is nil if raw is nil")
    }
}
