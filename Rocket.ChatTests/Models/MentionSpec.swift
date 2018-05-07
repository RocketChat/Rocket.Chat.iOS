//
//  MentionSpec.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/11/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class MentionSpec: XCTestCase {
    func testMap() {
        let mention = Mention()
        let username = "mention_username"

        let json = JSON(["username": username])

        mention.map(json, realm: nil)

        XCTAssert(mention.username == username, "will assign username")
    }
}
