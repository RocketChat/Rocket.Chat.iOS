//
//  MarkdownManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 4/13/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class MarkdownManagerSpec: XCTestCase {
    func testAlternateLinkCrashIsFixed() {
        let manager = MarkdownManager()
        let attributedString = NSAttributedString(string: "This should not crash: <https://a.b|a <b>>")
        let transformedAttributedString = manager.transformAttributedString(attributedString)
        XCTAssert(transformedAttributedString.string == "This should not crash: a <b>")
    }
}
