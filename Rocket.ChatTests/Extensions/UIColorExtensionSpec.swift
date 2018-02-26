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
        let name = SystemMessageColor.warning.rawValue
        let colorObject = SystemMessageColor(rawValue: name).color
        let colorResult = UIColor.normalizeColorFromString(string: name)
        XCTAssertEqual(colorResult.cgColor, colorObject.cgColor)
    }

    func testNormalizedColorFromStringDanger() {
        let name = SystemMessageColor.danger.rawValue
        let colorObject = SystemMessageColor(rawValue: name).color
        let colorResult = UIColor.normalizeColorFromString(string: name)
        XCTAssertEqual(colorResult.cgColor, colorObject.cgColor)
    }

    func testNormalizedColorFromStringGood() {
        let name = SystemMessageColor.good.rawValue
        let colorObject = SystemMessageColor(rawValue: name).color
        let colorResult = UIColor.normalizeColorFromString(string: name)
        XCTAssertEqual(colorResult.cgColor, colorObject.cgColor)
    }

    func testNormalizedColorFromStringOther() {
        let name = "#998800"
        let colorObject = SystemMessageColor(rawValue: name).color
        let colorResult = UIColor.normalizeColorFromString(string: name)
        XCTAssertEqual(colorResult.cgColor, colorObject.cgColor)
    }

}
