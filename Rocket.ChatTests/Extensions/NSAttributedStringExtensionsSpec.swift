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

    func testSetMention() {
        let string = "Hi @rafael.kellermann, how are you doing? Is everyone @here having a great day? How about you @filipe.alvarenga? Wish you @all a happy Christmas :) from @matheus.cardoso"

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
    }
}
