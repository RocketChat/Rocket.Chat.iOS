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
        XCTAssert(ResponseMessage(rawValue: "connected") == .connected, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "ping") == .ping, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "added") == .added, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "changed") == .changed, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "removed") == .removed, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "updated") == .updated, "Initializer results into a correct value")
        XCTAssert(ResponseMessage(rawValue: "foobar") == nil, "Initializer results into nil value")
    }

}
