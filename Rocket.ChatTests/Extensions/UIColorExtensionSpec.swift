//
//  UIColorExtensionSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 26/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class UIColorExtensionSpec: XCTestCase {

    func testNormalizedColorFromStringWarning() {
        let warningColor = UIColor.normalizeColorFromString(string: "warning")
        XCTAssertEqual(warningColor.hexDescription(), "fcb316")
    }

    func testNormalizedColorFromStringDanger() {
        let warningColor = UIColor.normalizeColorFromString(string: "danger")
        XCTAssertEqual(warningColor.hexDescription(), "d30230")
    }

    func testNormalizedColorFromStringGood() {
        let warningColor = UIColor.normalizeColorFromString(string: "good")
        XCTAssertEqual(warningColor.hexDescription(), "35ac19")
    }

    func testNormalizedColorFromStringOther() {
        let randomColor = "990088"
        let warningColor = UIColor.normalizeColorFromString(string: randomColor)
        XCTAssertEqual(warningColor.hexDescription(), randomColor)
    }

}
