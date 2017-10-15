//
//  AppManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 10/10/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class AppManagerSpec: XCTestCase {

    func testMultiServerSupport() {
        if AppManager.applicationServerURL != nil {
            XCTAssertFalse(AppManager.supportsMultiServer, "app does not support multi-server with static server")
        } else {
            XCTAssertTrue(AppManager.supportsMultiServer, "app supports multi-server with static server")
        }
    }

}
