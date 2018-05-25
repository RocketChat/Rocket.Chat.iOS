//
//  RoomRolesRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 11/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class RoomRolesRequestSpec: APITestCase {
    func testRequest() {
        let reactRequest = RoomRolesRequest(roomName: "general", subscriptionType: .channel)

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

        let result = RoomRolesResource(raw: json)
        XCTAssertEqual(result.roomRoles?.count, 2)
        XCTAssertEqual(result.roomRoles?.first?.user?.username, "john.appleseed")
        XCTAssertEqual(result.roomRoles?.first?.roles.count, 3)
        XCTAssertEqual(result.roomRoles?.first?.roles.first, Role.owner.rawValue)
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

        let result = RoomRolesResource(raw: json)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.roomRoles?.count, 1)
        XCTAssertEqual(result.roomRoles?.first?.roles.count, 3)
        XCTAssertNotNil(result.roomRoles?.first?.user)
        XCTAssertNil(result.roomRoles?.first?.user?.identifier)
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

        let result = RoomRolesResource(raw: json)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.roomRoles?.count, 1)
        XCTAssertEqual(result.roomRoles?.first?.roles.count, 3)
        XCTAssertNotNil(result.roomRoles?.first?.user)
        XCTAssertNil(result.roomRoles?.first?.user?.identifier)
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

        let result = RoomRolesResource(raw: json)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.roomRoles?.count, 1)
        XCTAssertEqual(result.roomRoles?.first?.roles.count, 3)
        XCTAssertNotNil(result.roomRoles?.first?.user)
        XCTAssertNil(result.roomRoles?.first?.user?.identifier)
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

        let result = RoomRolesResource(raw: json)
        XCTAssertTrue(result.success)
        XCTAssertEqual(result.roomRoles?.count, 1)
        XCTAssertEqual(result.roomRoles?.first?.roles.count, 0)
        XCTAssertEqual(result.roomRoles?.first?.user?.username, "john.appleseed")
    }

    func testEmptyResults() {
        let nilResult = RoomRolesResource(raw: nil)
        XCTAssertNil(nilResult.roomRoles)
    }

}
