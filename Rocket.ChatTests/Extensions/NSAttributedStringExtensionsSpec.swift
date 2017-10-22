//
//  NSAttributedStringExtensionsSpec.swift
//  Rocket.Chat
//
//  Created by Matheus Martins on 9/11/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

private func assert<T: Equatable>(_ attributedString: NSAttributedString,
                                  has attribute: (NSAttributedStringKey, T),
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
        guard let _wordRange = attributedString.string.range(of: "word")
            else { XCTFail("This will never happen!"); return }
        let wordRange = NSRange(_wordRange, in: attributedString.string)
        let font = UIFont.italicSystemFont(ofSize: 12)
        attributedString.setFont(font, range: wordRange)

        assert(attributedString, has: (NSAttributedStringKey.font, font), in: wordRange, "setFont will work")
    }

    func testSetFontColor() {
        let attributedString = NSMutableAttributedString(string: "this > word < is red")
        guard let _wordRange = attributedString.string.range(of: "word")
            else { XCTFail("This will never happen!"); return }
        let wordRange = NSRange(_wordRange, in: attributedString.string)
        let color = UIColor.red
        attributedString.setFontColor(color, range: wordRange)

        assert(attributedString, has: (NSAttributedStringKey.foregroundColor, color), in: wordRange, "setFontColor will work")
    }

    func testSetBackgroundColor() {
        let attributedString = NSMutableAttributedString(string: "this > word < is red on the background")
        guard let _wordRange = attributedString.string.range(of: "word")
            else { XCTFail("This will never happen!"); return }
        let wordRange = NSRange(_wordRange, in: attributedString.string)
        let color = UIColor.red
        attributedString.setBackgroundColor(color, range: wordRange)

        assert(attributedString, has: (NSAttributedStringKey(rawValue: "highlightColor"), color), in: wordRange, "setBackgroundColor will work")
    }
}
