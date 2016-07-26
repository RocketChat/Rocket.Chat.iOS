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
        XCTAssert(ResponseMessage("connected")! == .Connected, "Initializer results into a correct value")
        XCTAssert(ResponseMessage("ping")! == .Ping, "Initializer results into a correct value")
        XCTAssert(ResponseMessage("added")! == .Added, "Initializer results into a correct value")
        XCTAssert(ResponseMessage("changed")! == .Changed, "Initializer results into a correct value")
        XCTAssert(ResponseMessage("removed")! == .Removed, "Initializer results into a correct value")
        XCTAssert(ResponseMessage("updated")! == .Updated, "Initializer results into a correct value")
        XCTAssert(ResponseMessage("foobar")! == .Unknown, "Initializer results into unknown value")
        XCTAssert(ResponseMessage("")! == .Unknown, "Initializer results into unknown value")
    }

}
