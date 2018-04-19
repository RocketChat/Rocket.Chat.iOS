//
//  InfoRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class InfoRequestSpec: APITestCase {
    func testRequest() {
        let preRequest = InfoRequest()
        let request1 = preRequest.request(for: api)
        let expectedURL = api.host.appendingPathComponent(preRequest.path)
        XCTAssertEqual(request1?.url, expectedURL, "url is correct")
        XCTAssertEqual(request1?.httpMethod, "GET", "http method is correct")
    }

    func testProperties() {
        let jsonString = """
        {
            "success": true,
            "info": {
                "version": "0.47.0-develop",
                "build": {
                    "nodeVersion": "v4.6.2",
                    "arch": "x64",
                    "platform": "linux",
                    "cpus": 4
                },
                "commit": {
                    "hash": "5901cc7270e3587101631ee222def950d705c611",
                    "date": "Thu Dec 1 19:08:01 2016 -0200",
                    "author": "Gabriel Engel",
                    "subject": "Merge branch 'develop' into experimental",
                    "tag": "0.46.0",
                    "branch": "experimental"
                }
            }
        }
        """

        let json = JSON(parseJSON: jsonString)

        let resource = InfoResource(raw: json)

        XCTAssertEqual(resource.version, "0.47.0-develop")
    }
}
