//
//  VersionMiddlewareSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class VersionMiddlewareSpec: XCTestCase {
    class TestRequest: APIRequest {
        let path = "/test"
        var requiredVersion = Version(major: 0, minor: 60, patch: 0)
    }

    func testHandleRequest() {
        let available = Version(major: 0, minor: 60, patch: 0)
        let required = Version(major: 0, minor: 61, patch: 0)

        let api: API! = API(host: "https://open.rocket.chat", version: available)
        let middleware = VersionMiddleware(api: api)

        var request = TestRequest()
        request.requiredVersion = required

        guard
            let error = middleware.handle(&request),
            case let .version(_available, _required) = error
        else {
            return XCTFail("should return APIError.version")
        }

        XCTAssertEqual(_available, available)
        XCTAssertEqual(_required, required)

        request.requiredVersion = .zero

        XCTAssertNil(middleware.handle(&request))
    }
}
