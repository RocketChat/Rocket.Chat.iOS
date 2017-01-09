//
//  StringExtensionSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class StringExtensionSpec: XCTestCase {

    // MARK: Random string

    func testRandomStringIsAlwaysDifferent() {
        let string1 = String.random()
        let string2 = String.random()
        XCTAssert(string1 != string2, "Random strings are always different")
    }

    func testRandomStringCanHaveDifferentSizes() {
        XCTAssert(String.random(10).characters.count == 10, "Random string have 10 characters")
        XCTAssert(String.random(20).characters.count == 20, "Random string have 20 characters")
        XCTAssert(String.random(100).characters.count == 100, "Random string have 100 characters")
    }

    // MARK: SHA-256

    func testSHA256ReturnsString() {
        let string = "foobar"
        let hash = "c3ab8ff13720e8ad9047dd39466b3c8974e592c2fa383d4a3960714caef0c4f2"
        XCTAssert(string.sha256() == hash, "String SHA-256 cryptographic is correct")
    }

}
