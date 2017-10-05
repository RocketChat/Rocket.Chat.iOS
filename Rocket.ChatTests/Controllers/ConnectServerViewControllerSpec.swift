//
//  ConnectServerViewControllerSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 10/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ConnectServerViewControllerSpec: XCTestCase {
    func testNormalizeInputURL() {
        let vc = ConnectServerViewController()

        XCTAssertEqual(vc.normalizeInputURL("open.rocket.chat"), "https://open.rocket.chat", "will add https")
        XCTAssertEqual(vc.normalizeInputURL("https://open.rocket.chat"), "https://open.rocket.chat", "will return correct url")
        XCTAssertEqual(vc.normalizeInputURL("http://open.rocket.chat"), "https://open.rocket.chat", "will force https scheme")
        XCTAssertNil(vc.normalizeInputURL("https://"), "will return nil when hostless")
        XCTAssertNil(vc.normalizeInputURL(""), "will return nil when empty")
    }
}

