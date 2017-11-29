//
//  APIExtensionsSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class APIExtensionsSpec: XCTestCase {
    func testCurrent() {
        var auth = Auth.testInstance()
        var api = API.current(auth: auth)

        XCTAssertEqual(api?.userId, "auth-userid")
        XCTAssertEqual(api?.authToken, "auth-token")
        XCTAssertEqual(api?.version, Version(1, 2, 3))

        auth.serverVersion = "invalid"
        api = API.current(auth: auth)
        XCTAssertEqual(api?.version, Version.zero)

        auth = Auth()
        api = API.current(auth: auth)

        XCTAssertNil(api)
    }
}
