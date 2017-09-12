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

    func testIsConnected() {
        let manager = NetworkManager()

        if manager.reachability?.currentReachabilityStatus == .notReachable {
            XCTAssertFalse(manager.isConnected, "connected is false when Reachability status is .notReachable")
        } else {
            XCTAssertTrue(manager.isConnected, "connected is true when Reachability status is reachable")
        }
    }

    func testReachbilityNotNil() {
        let manager = NetworkManager()
        XCTAssertNotNil(manager.reachability, "reachability is not nil after init")
    }

    func testSharedInstanceNotNil() {
        let manager = NetworkManager.shared
        XCTAssertNotNil(manager, "shared instance isn't nil")
    }

}
