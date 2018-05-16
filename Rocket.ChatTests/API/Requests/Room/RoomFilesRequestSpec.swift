//
//  RoomFilesRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 02/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class RoomFilesRequestSpec: APITestCase {

    func testRequest() {
        let preRequest = RoomFilesRequest(roomId: "xyz123", subscriptionType: .channel)
        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        var components = URLComponents(url: api.host, resolvingAgainstBaseURL: false)
        components?.path = preRequest.path
        components?.query = preRequest.query

        let expectedURL = components?.url

        XCTAssertEqual(preRequest.path, "/api/v1/channels.files", "request path is correct")
        XCTAssertEqual(request.url, expectedURL, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    //swiftlint:disable function_body_length
    func testProperties() {
        let jsonString =
        """
            {
                "files": [
                    {
                        "_id": "S78TNnvaWGwdYRaCD",
                        "name": "images.jpeg",
                        "size": 9778,
                        "type": "image/jpeg",
                        "rid": "GENERAL",
                        "description": "",
                        "store": "GridFS:Uploads",
                        "complete": true,
                        "uploading": false,
                        "extension": "jpeg",
                        "progress": 1,
                        "user": {
                            "_id": "ksKsKmrjvxzkzxkww",
                            "username": "rocket.cat",
                            "name": "Rocket Cat"
                        },
                        "_updatedAt": "2018-03-08T14:47:37.003Z",
                        "instanceId": "uZG54xuoKauKHykbQ",
                        "etag": "jPaviS9qG22xC5sDC",
                        "path": "/ufs/GridFS:Uploads/S78TNnvaWGwdYRaCD/images.jpeg",
                        "token": "28cAb868d9",
                        "uploadedAt": "2018-03-08T14:47:37.295Z",
                        "url": "/ufs/GridFS:Uploads/S78TNnvaWGwdYRaCD/images.jpeg"
                    }
                ],
                "count": 1,
                "offset": 0,
                "total": 1,
                "success": true
            }
        """

        let json = JSON(parseJSON: jsonString)

        let result = RoomFilesResource(raw: json)
        XCTAssertNotNil(result.files)
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.offset, 0)
        XCTAssertEqual(result.total, 1)
        XCTAssertTrue(result.success)

        let nilResult = RoomFilesResource(raw: nil)
        XCTAssertNil(nilResult.files)
    }

}
