//
//  PermissionsRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 5/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class PermissionsRequestSpec: APITestCase {
    func testRequest() {
        let preRequest = InfoRequest()
        let request1 = preRequest.request(for: api)
        let expectedURL = api.host.appendingPathComponent(preRequest.path)
        XCTAssertEqual(request1?.url, expectedURL, "url is correct")
        XCTAssertEqual(request1?.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let json = JSON([
            [
                "_id": "snippet-message",
                "roles": [
                    "owner",
                    "moderator",
                    "admin"
                ]
            ],
            [
                "_id": "access-permissions",
                "roles": [
                    "admin"
                ]
            ]
        ])

        let resource = PermissionsResource(raw: json)

        XCTAssertEqual(resource.permissions.count, 2)
        XCTAssertEqual(resource.permissions[0].identifier, "snippet-message")
        XCTAssertEqual(resource.permissions[0].roles.count, 3)
        XCTAssertEqual(resource.permissions[1].identifier, "access-permissions")
        XCTAssertEqual(resource.permissions[1].roles.count, 1)
    }
}
