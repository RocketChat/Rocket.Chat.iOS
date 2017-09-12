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

    func testRangesOf() {
        let string = "this word is in position 5 and this word is in position 36"
        let ranges = string.ranges(of: "word")

        XCTAssert(ranges.count == 2, "will find correct number of words")
        XCTAssert(string.distance(from: string.startIndex, to: ranges[0].lowerBound) == 5, "will find word 1 in correct place")
        XCTAssert(string.distance(from: string.startIndex, to: ranges[1].lowerBound) == 36, "will find word 2 in correct place")
        XCTAssert(string.distance(from: ranges[0].lowerBound, to: ranges[0].upperBound) == 4, "will word 1 have correct size")
        XCTAssert(string.distance(from: ranges[1].lowerBound, to: ranges[1].upperBound) == 4, "will word 2 have correct size")
    }
}
