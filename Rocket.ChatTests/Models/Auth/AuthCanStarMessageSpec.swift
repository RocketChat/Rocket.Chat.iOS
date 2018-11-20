//
//  AuthCanStarMessageSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 4/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class AuthCanStarMessageSpec: XCTestCase {
    func testCanStarMessage() {
        let auth = Auth.testInstance()

        let message = Message.testInstance()
        message.identifier = "mid"

        Realm.execute({ realm in
            realm.add(auth)
            auth.settings?.messageAllowStarring = true
        })

        // User & Server have permission
        XCTAssertEqual(auth.canStarMessage(message), .allowed)

        // Message is not actionable
        Realm.execute({ _ in
            message.createdAt = Date()
            message.internalType = MessageType.userJoined.rawValue
        })

        XCTAssertEqual(auth.canStarMessage(message), .notActionable)

        // Server permission doesn't allow to pin
        Realm.execute({ _ in
            message.internalType = MessageType.text.rawValue
            auth.settings?.messageAllowStarring = false
        })

        XCTAssertEqual(auth.canStarMessage(message), .notAllowed)

        // Settings is nil
        Realm.execute({ _ in
            auth.settings = nil
        })

        XCTAssertEqual(auth.canStarMessage(message), .unknown)
    }
}
