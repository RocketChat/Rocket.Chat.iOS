//
//  NSAttributedStringExtensionsSpec.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/11/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

private func assert<T: Equatable>(_ attributedString: NSAttributedString,
                                  has attribute: (NSAttributedString.Key, T),
                                  in range: NSRange, _ message: String) {
    attributedString.enumerateAttributes(in: range, options: [], using: { attributes, crange, _ in
        XCTAssert(Range(range) == Range(crange) && attributes[attribute.0] as? T == attribute.1, message)
    })
}

class NSAttributedStringExtensionsSpec: XCTestCase {
    func testTrimCharacters() {
        let attributedString = NSMutableAttributedString(string: "  a  ")
        attributedString.trimCharacters(in: .whitespaces)
        XCTAssert(attributedString.string == "a", "trimCharacters will trim white spaces")
    }

    func testSetFont() {
        let attributedString = NSMutableAttributedString(string: "this > word < is italic")
        guard let matchWordRange = attributedString.string.range(of: "word") else {
            return XCTFail("This will never happen!")
        }

        let wordRange = NSRange(matchWordRange, in: attributedString.string)
        let font = UIFont.italicSystemFont(ofSize: 12)
        attributedString.setFont(font, range: wordRange)

        assert(attributedString, has: (NSAttributedString.Key.font, font), in: wordRange, "setFont will work")
    }

    func testSetFontColor() {
        let attributedString = NSMutableAttributedString(string: "this > word < is red")
        guard let matchWordRange = attributedString.string.range(of: "word") else {
            return XCTFail("This will never happen!")
        }

        let wordRange = NSRange(matchWordRange, in: attributedString.string)
        let color = UIColor.red
        attributedString.setFontColor(color, range: wordRange)

        assert(attributedString, has: (NSAttributedString.Key.foregroundColor, color), in: wordRange, "setFontColor will work")
    }

    func testSetBackgroundColor() {
        let attributedString = NSMutableAttributedString(string: "this > word < is red on the background")
        guard let matchWordRange = attributedString.string.range(of: "word") else {
            return XCTFail("This will never happen!")
        }

        let wordRange = NSRange(matchWordRange, in: attributedString.string)
        let color = UIColor.red
        attributedString.setBackgroundColor(color, range: wordRange)

        assert(attributedString, has: (NSAttributedString.Key.backgroundColor, color), in: wordRange, "setBackgroundColor will work")
    }

    // swiftlint:disable function_body_length
    func testMentionParsing() {
        let string = "Hi @rafael.kellermann, how are you doing? " +
                     "Is everyone @here having a great day? How about you @filipe.alvarenga? Wish you @all a happy Christmas :) from @matheus.cardoso"

        let result = NSMutableAttributedString(string: string)

        result.highlightMentions([
                UnmanagedMention(userId: nil, realName: nil, username: "rafael.kellermann"),
                UnmanagedMention(userId: nil, realName: nil, username: "here"),
                UnmanagedMention(userId: nil, realName: nil, username: "filipe.alvarenga"),
                UnmanagedMention(userId: nil, realName: nil, username: "all"),
                UnmanagedMention(userId: nil, realName: nil, username: "matheus.cardoso")
            ],
            currentUsername: "matheus.cardoso"
        )

        XCTAssertEqual(
            result.string,
            "Hi \u{00a0}rafael.kellermann\u{00a0}, how are you doing? Is everyone \u{00a0}here\u{00a0} having a great day? How about you \u{00a0}filipe.alvarenga\u{00a0}? Wish you \u{00a0}all\u{00a0} a happy Christmas :) from \u{00a0}matheus.cardoso\u{00a0}",
            "removes at symbols and adds spacing in mentions"
        )

        let nsString = NSString(string: result.string)

        let range0 = nsString.range(of: "Hi ")
        let attributes0 = result.attributes(at: range0.location, longestEffectiveRange: nil, in: range0)
        XCTAssertEqual(attributes0.count, 0, "Will have no attributes")

        let range1 = nsString.range(of: "\u{00a0}rafael.kellermann\u{00a0}")
        let attributes1 = result.attributes(at: range1.location, longestEffectiveRange: nil, in: range1)
        XCTAssertEqual(attributes1.count, 4, "Will have 4 attributes")
        XCTAssertEqual(attributes1[.link] as? String, "rocketchat://mention?name=rafael.kellermann")
        XCTAssertEqual(attributes1[.backgroundColor] as? UIColor, Theme.light.actionBackgroundColor)
        XCTAssertEqual(attributes1[.foregroundColor] as? UIColor, Theme.light.actionTintColor)
        XCTAssertEqual(attributes1[.font] as? UIFont, MessageTextFontAttributes.boldFont)

        let range2 = nsString.range(of: ", how are you doing? Is everyone ")
        let attributes2 = result.attributes(at: range2.location, longestEffectiveRange: nil, in: range2)
        XCTAssertEqual(attributes2.count, 0, "Will have no attributes")

        let range3 = nsString.range(of: "\u{00a0}here\u{00a0}")
        let attributes3 = result.attributes(at: range3.location, longestEffectiveRange: nil, in: range3)
        XCTAssertEqual(attributes3.count, 3, "Will have 3 attributes")
        XCTAssertEqual(attributes3[.backgroundColor] as? UIColor, .attention)
        XCTAssertEqual(attributes3[.foregroundColor] as? UIColor, .white)
        XCTAssertEqual(attributes3[.font] as? UIFont, MessageTextFontAttributes.boldFont)

        let range4 = nsString.range(of: " having a great day? How about you ")
        let attributes4 = result.attributes(at: range4.location, longestEffectiveRange: nil, in: range4)
        XCTAssertEqual(attributes4.count, 0, "Will have no attributes")

        let range5 = nsString.range(of: "\u{00a0}filipe.alvarenga\u{00a0}")
        let attributes5 = result.attributes(at: range5.location, longestEffectiveRange: nil, in: range5)
        XCTAssertEqual(attributes5.count, 4, "Will have 4 attributes")
        XCTAssertEqual(attributes5[.link] as? String, "rocketchat://mention?name=filipe.alvarenga")
        XCTAssertEqual(attributes5[.backgroundColor] as? UIColor, Theme.light.actionBackgroundColor)
        XCTAssertEqual(attributes5[.foregroundColor] as? UIColor, Theme.light.actionTintColor)
        XCTAssertEqual(attributes5[.font] as? UIFont, MessageTextFontAttributes.boldFont)

        let range6 = nsString.range(of: "? Wish you ")
        let attributes6 = result.attributes(at: range6.location, longestEffectiveRange: nil, in: range6)
        XCTAssertEqual(attributes6.count, 0, "Will have no attributes")

        let range7 = nsString.range(of: "\u{00a0}all\u{00a0}")
        let attributes7 = result.attributes(at: range7.location, longestEffectiveRange: nil, in: range7)
        XCTAssertEqual(attributes7.count, 3, "Will have 3 attributes")
        XCTAssertEqual(attributes7[.backgroundColor] as? UIColor, .attention)
        XCTAssertEqual(attributes7[.foregroundColor] as? UIColor, .white)
        XCTAssertEqual(attributes7[.font] as? UIFont, MessageTextFontAttributes.boldFont)

        let range8 = nsString.range(of: " a happy Christmas :) from ")
        let attributes8 = result.attributes(at: range8.location, longestEffectiveRange: nil, in: range8)
        XCTAssertEqual(attributes8.count, 0, "Will have no attributes")

        let range9 = nsString.range(of: "\u{00a0}matheus.cardoso\u{00a0}")
        let attributes9 = result.attributes(at: range9.location, longestEffectiveRange: nil, in: range9)
        XCTAssertEqual(attributes9.count, 3, "Will have 3 attributes")
        XCTAssertEqual(attributes9[.backgroundColor] as? UIColor, Theme.light.actionTintColor)
        XCTAssertEqual(attributes9[.foregroundColor] as? UIColor, .white)
        XCTAssertEqual(attributes9[.font] as? UIFont, MessageTextFontAttributes.boldFont)
    }
}
