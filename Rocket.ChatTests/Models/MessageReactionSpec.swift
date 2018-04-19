//
//  MessageReactionSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 12/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

class MessageReactionSpec: XCTestCase {
    func testMap() {
        let object = MessageReaction()
        object.map(emoji: ":smile:", json: JSON([
            "usernames": [
                "user1",
                "user2",
                "user3"
            ]
        ]))

        XCTAssertEqual(object.emoji, ":smile:")
    }
}
