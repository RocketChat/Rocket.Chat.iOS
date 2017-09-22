//
//  NetworkManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 12/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class NetworkManagerSpec: XCTestCase {

    func testReachbilityNotNil() {
        let manager = NetworkManager.shared
        manager.start()

        XCTAssertNotNil(manager.reachability, "reachability is not nil after init")
    }

    func testSharedInstanceNotNil() {
        let manager = NetworkManager.shared
        XCTAssertNotNil(manager, "shared instance isn't nil")
    }

}
