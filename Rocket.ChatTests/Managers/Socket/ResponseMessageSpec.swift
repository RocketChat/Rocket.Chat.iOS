//
//  ResponseMessageSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/26/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class ResponseMessageSpec: XCTestCase {

    func testInitializer() {
        XCTAssert(ResponseMessage(rawValue: "connected") == .Connected, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "ping") == .Ping, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "added") == .Added, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "changed") == .Changed, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "removed") == .Removed, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "updated") == .Updated, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "foobar") == nil, "Initializer results into nil value")
    }

}
