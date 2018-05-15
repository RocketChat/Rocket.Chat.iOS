//
//  SubscriptionRolesRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 11/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SubscriptionRolesRequestSpec: APITestCase {
    func testRequest() {
        let reactRequest = SubscriptionRolesRequest(roomName: "general", subscriptionType: .channel)

        guard let request = reactRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        XCTAssertEqual(request.url?.path, "/api/v1/channels.roles", "path is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
        XCTAssertEqual(request.url?.query, "roomName=general", "query value is correct")
        XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json", "content type is correct")
    }

    func testResult() {
        let jsonString = """
        {
            "roles": [{
                    "u": {
                        "name": "John Appleseed",
                        "username": "john.appleseed",
                        "_id": "Xx6KW6XQsFkmDPGdE"
                    },
                    "_id": "j2pdXnucQbLg5WXRu",
                    "rid": "ABsnusN6m9h7Z7KnR",
                    "roles": [
                        "owner",
                        "moderator",
                        "leader"
                    ]
                },{
                    "u": {
                        "name": "John Applesee 2",
                        "username": "john.appleseed.2",
                        "_id": "xyJPCay3ShCQyuezh"
                    },
                    "_id": "oCMaLjQ74HuhSEW9g",
                    "rid": "ABsnusN6m9h7Z7KnR",
                    "roles": [
                        "moderator"
                    ]
                }
            ],
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = SubscriptionRolesResource(raw: json)
        XCTAssertEqual(result.subscriptionRoles?.count, 2)
        XCTAssertEqual(result.subscriptionRoles?.first?.user?.username, "john.appleseed")
        XCTAssertEqual(result.subscriptionRoles?.first?.roles.count, 3)
        XCTAssertEqual(result.subscriptionRoles?.first?.roles.first, Role.owner.rawValue)
        XCTAssertTrue(result.success)
    }

    func testNullUserObject() {
        let jsonString = """
        {
            "roles": [{
                    "u": null,
                    "_id": "j2pdXnucQbLg5WXRu",
                    "rid": "ABsnusN6m9h7Z7KnR",
                    "roles": [
                        "owner",
                        "moderator",
                        "leader"
                    ]
                }
            ],
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = SubscriptionRolesResource(raw: json)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.subscriptionRoles?.count, 1)
        XCTAssertEqual(result.subscriptionRoles?.first?.roles.count, 3)
        XCTAssertNotNil(result.subscriptionRoles?.first?.user)
        XCTAssertNil(result.subscriptionRoles?.first?.user?.identifier)
    }

    func testInvalidUserObject() {
        let jsonString = """
        {
            "roles": [{
                    "u": {
                        "foo": "bar"
                    },
                    "_id": "j2pdXnucQbLg5WXRu",
                    "rid": "ABsnusN6m9h7Z7KnR",
                    "roles": [
                        "owner",
                        "moderator",
                        "leader"
                    ]
                }
            ],
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = SubscriptionRolesResource(raw: json)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.subscriptionRoles?.count, 1)
        XCTAssertEqual(result.subscriptionRoles?.first?.roles.count, 3)
        XCTAssertNotNil(result.subscriptionRoles?.first?.user)
        XCTAssertNil(result.subscriptionRoles?.first?.user?.identifier)
    }

    func testArrayUserObject() {
        let jsonString = """
        {
            "roles": [{
                    "u": ["foo"],
                    "_id": "j2pdXnucQbLg5WXRu",
                    "rid": "ABsnusN6m9h7Z7KnR",
                    "roles": [
                        "owner",
                        "moderator",
                        "leader"
                    ]
                }
            ],
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = SubscriptionRolesResource(raw: json)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.subscriptionRoles?.count, 1)
        XCTAssertEqual(result.subscriptionRoles?.first?.roles.count, 3)
        XCTAssertNotNil(result.subscriptionRoles?.first?.user)
        XCTAssertNil(result.subscriptionRoles?.first?.user?.identifier)
    }

    func testEmtpyRolesObject() {
        let jsonString = """
        {
            "roles": [{
                    "u": {
                        "name": "John Appleseed",
                        "username": "john.appleseed",
                        "_id": "Xx6KW6XQsFkmDPGdE"
                    },
                    "_id": "j2pdXnucQbLg5WXRu",
                    "rid": "ABsnusN6m9h7Z7KnR",
                    "roles": [ ]
                }
            ],
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let result = SubscriptionRolesResource(raw: json)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.subscriptionRoles?.count, 1)
        XCTAssertEqual(result.subscriptionRoles?.first?.roles.count, 0)
        XCTAssertEqual(result.subscriptionRoles?.first?.user?.username, "john.appleseed")
    }

    func testEmptyResults() {
        let nilResult = SubscriptionRolesResource(raw: nil)
        XCTAssertNil(nilResult.subscriptionRoles)
    }

}
