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
            "version": "1.2.3-develop",
            "success": true
        }
        """

        let json = JSON(parseJSON: jsonString)

        let resource = InfoResource(raw: json)

        XCTAssertEqual(resource.version, "1.2.3-develop")
    }
}
