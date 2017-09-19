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

class InfoRequestSpec: XCTestCase {
    func testRequestNotNil() {
        XCTAssertNotNil(InfoRequest().request(for: API.shared), "request is not nil")
    }

    func testRequestNil() {
        XCTAssertNil(InfoRequest().request(for: API(host: "malformed host")), "request is nil")
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

        let result = InfoResult(raw: json)

        XCTAssertEqual(result.version, "0.47.0-develop")
    }
}
