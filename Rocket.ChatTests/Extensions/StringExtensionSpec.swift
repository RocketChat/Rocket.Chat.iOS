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
        XCTAssert(String.random(10).count == 10, "Random string have 10 characters")
        XCTAssert(String.random(20).count == 20, "Random string have 20 characters")
        XCTAssert(String.random(100).count == 100, "Random string have 100 characters")
    }

    // MARK: SHA-256

    func testSHA256ReturnsString() {
        let string = "foobar"
        let hash = "c3ab8ff13720e8ad9047dd39466b3c8974e592c2fa383d4a3960714caef0c4f2"
        XCTAssert(string.sha256() == hash, "String SHA-256 cryptographic is correct")
    }

    // MARK: Removing Last Slash (when needed)

    func testRemovingLastSlashURLPresent() {
        XCTAssertEqual("http://foo.bar/".removingLastSlashIfNeeded(), "http://foo.bar")
        XCTAssertEqual("http://foo.bar/foo/bar/".removingLastSlashIfNeeded(), "http://foo.bar/foo/bar")
        XCTAssertEqual("http://foo.bar/foo/bar/?12345".removingLastSlashIfNeeded(), "http://foo.bar/foo/bar/?12345")
    }

    func testRemovingLastSlashURLNotPresent() {
        XCTAssertEqual("foo".removingLastSlashIfNeeded(), "foo")
        XCTAssertEqual("http://foo.bar".removingLastSlashIfNeeded(), "http://foo.bar")
    }

    // MARK: Range

    func testRangesOf() {
        let string = "this word is in position 5 and this word is in position 36"
        let ranges = string.ranges(of: "word")

        XCTAssert(ranges.count == 2, "will find correct number of words")
        XCTAssert(string.distance(from: string.startIndex, to: ranges[0].lowerBound) == 5, "will find word 1 in correct place")
        XCTAssert(string.distance(from: string.startIndex, to: ranges[1].lowerBound) == 36, "will find word 2 in correct place")
        XCTAssert(string.distance(from: ranges[0].lowerBound, to: ranges[0].upperBound) == 4, "will word 1 have correct size")
        XCTAssert(string.distance(from: ranges[1].lowerBound, to: ranges[1].upperBound) == 4, "will word 2 have correct size")
    }

    func testRemovingWhitespaces() {
        // arrange
        let withWhitespaces1 = "a b c d "
        let expected1 = "abcd"

        let withWhitespaces2 = " a b c d "
        let expected2 = "abcd"

        let withWhitespaces3 = " a      b c d "
        let expected3 = "abcd"

        let withWhitespaces4 = "  "
        let expected4 = ""

        let withWhitespaces5 = " a "
        let expected5 = "a"

        // act
        let result1 = withWhitespaces1.removingWhitespaces()
        let result2 = withWhitespaces2.removingWhitespaces()
        let result3 = withWhitespaces3.removingWhitespaces()
        let result4 = withWhitespaces4.removingWhitespaces()
        let result5 = withWhitespaces5.removingWhitespaces()

        // assert
        XCTAssertEqual(result1, expected1, "string has no whitespaces")
        XCTAssertEqual(result2, expected2, "string has no whitespaces")
        XCTAssertEqual(result3, expected3, "string has no whitespaces")
        XCTAssertEqual(result4, expected4, "string has no whitespaces")
        XCTAssertEqual(result5, expected5, "string has no whitespaces")
    }

    func testRemovingWhitespacesAndNewlines() {
        let withWhitespaces1 = "a b\n\n c\n d \n"
        let expected1 = "abcd"

        let withWhitespaces2 = "\n\n\n\n\n\nabcd"
        let expected2 = "abcd"

        let result1 = withWhitespaces1.removingWhitespaces()
        let result2 = withWhitespaces2.removingWhitespaces()

        XCTAssertEqual(result1, expected1, "string has no whitespaces and no new lines")
        XCTAssertEqual(result2, expected2, "string has no whitespaces and no new lines")
    }

    func testNewlines() {
        let withWhitespaces1 = "a b\n\n c\n d \n"
        let expected1 = "a b c d "

        let withWhitespaces2 = "\n\n\n\n\n\nabcd"
        let expected2 = "abcd"

        let result1 = withWhitespaces1.removingNewLines()
        let result2 = withWhitespaces2.removingNewLines()

        XCTAssertEqual(result1, expected1, "string has no new lines")
        XCTAssertEqual(result2, expected2, "string has no new lines")
    }

    // MARK: Base64

    func testBase64() {
        XCTAssertEqual("test".base64Encoded(), "dGVzdA==", "base64Encoded encodes correctly")
        XCTAssertEqual("dGVzdA==".base64Decoded(), "test", "base64Decoded decodes correctly")

        let randomString = String.random(10)
        XCTAssertEqual(randomString.base64Encoded()?.base64Decoded(), randomString, "base64Encoded <-> base64Decoded pass random test")
    }

    // MARK: Others

    func testCommandAndParams() {
        let string = "/gimme hello world"

        guard let (command, params) = string.commandAndParams() else {
            return XCTFail("string is valid command")
        }

        XCTAssertEqual(command, "gimme")
        XCTAssertEqual(params, "hello world")

        let string2 = "gimme"

        XCTAssertNil(string2.commandAndParams())
    }
}
