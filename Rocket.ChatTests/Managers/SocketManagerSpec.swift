//
//  SocketManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SocketManagerSpec: XCTestCase {

    // MARK: SocketResponse

    func testSocketResponseErrorMethodMsgError() {
        let result = JSON(["msg": "error", "foo": "bar"])
        let response = SocketResponse(result, socket: nil)
        XCTAssert(response?.isError() == true, "isError() should return true when JSON object contains {'msg': 'error'}")
    }

    func testSocketResponseErrorObjectError() {
        let result = JSON(["msg": "result", "error": []])
        let response = SocketResponse(result, socket: nil)
        XCTAssert(response?.isError() == true, "isError() should return true when JSON object contains {'error': [...]}")
    }

    func testSocketResponseErrorFalse() {
        let result = JSON(["msg": "result", "foo": "bar", "fields": ["eventName": "event"]])
        let response = SocketResponse(result, socket: nil)
        XCTAssert(response?.isError() == false, "isError() should return true when JSON don't contains error")
    }

}
