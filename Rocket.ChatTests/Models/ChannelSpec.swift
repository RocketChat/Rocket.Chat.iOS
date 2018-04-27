//
//  ChannelSpec.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/11/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class ChannelSpec: XCTestCase {
    func testMap() {
        let channel = Channel()
        let name = "channel_name"

        let json = JSON(["name": name])

        channel.map(json, realm: nil)

        XCTAssert(channel.name == name, "will assign name")
    }
}
