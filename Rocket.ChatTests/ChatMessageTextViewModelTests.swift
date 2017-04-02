//
//  ChatMessageTextViewModelTests.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 01/04/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ChatMessageTextViewModelTests: XCTestCase {

    func testValidColor() {
        let attachment = Attachment()
        attachment.color = "#C1272D"
        let color = UIColor(hex: "#C1272D")
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        XCTAssert(model.color == color, "Should have a valid color for a valid hexa code")
    }

    func testNilColor() {
        let attachment = Attachment()
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        XCTAssert(model.color == UIColor.lightGray, "Should have a light gray color for an invalid hexa code")
    }

    func testTitle() {
        let attachment = Attachment()
        attachment.title = "Message title"
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        XCTAssert(model.title == attachment.title, "Should have a title")
    }

    func testText() {
        let attachment = Attachment()
        attachment.text = "Lorem ipsum"
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        XCTAssert(model.text == attachment.text, "Should have a text")
    }

    func testNilText() {
        let attachment = Attachment()
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        XCTAssert(model.text == "", "Should have a nil text")
    }

    func testThumbURL() {
        let attachment = Attachment()
        attachment.thumbURL = "http://rocket.chat"
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        guard let url = attachment.thumbURL else {
            XCTFail("Can't parse nil url string")
            return
        }

        XCTAssert(model.thumbURL == URL(string: url), "Should have a thumb url")
    }

    func testNilThumbURL() {
        let attachment = Attachment()
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        guard attachment.thumbURL != nil else {
            XCTAssert(model.thumbURL == nil, "Should have a thumb url")
            return
        }

        XCTFail("Should not have an URL")
    }

    func testCollapsed() {
        let attachment = Attachment()
        attachment.collapsed = true
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        XCTAssertTrue(model.collapsed)
    }

    func testNotCollapsed() {
        let attachment = Attachment()
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        XCTAssertFalse(model.collapsed)
    }

    func testToggleCollpased() {
        let attachment = Attachment()
        let model = ChatMessageTextViewModel(withAttachment: attachment)
        model.toggleCollpase()

        XCTAssertTrue(model.collapsed)
    }
}