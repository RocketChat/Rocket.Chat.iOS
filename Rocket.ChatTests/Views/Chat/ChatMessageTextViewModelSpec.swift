//
//  ChatMessageTextViewModelSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Machado on 01/04/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ChatMessageTextViewModelSpec: XCTestCase {

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

        XCTAssert(model.title == "▼ Message title", "ucollapsed test is correct")

        attachment.collapsed = true

        XCTAssert(model.title == "▶ Message title", "collapsed test is correct")

        // Don't display collapse icon for files

        attachment.titleLinkDownload = true
        attachment.titleLink = "test"

        XCTAssert(model.title == "Message title")
    }

    func testText() {
        let attachment = Attachment()
        attachment.text = "Lorem ipsum"
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        XCTAssert(model.text == "Lorem ipsum", "text is correct")

    }

    func testTextTitleLink() {
        let attachment = Attachment()
        attachment.text = "Lorem ipsum"
        attachment.titleLink = "http://foo.bar"
        let model = ChatMessageTextViewModel(withAttachment: attachment)

        XCTAssert(model.text == localized("chat.message.open_file"), "Should have a text")
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

    func testToggleCollapsed() {
        let attachment = Attachment()
        let model = ChatMessageTextViewModel(withAttachment: attachment)
        model.toggleCollapse()
        XCTAssertTrue(model.collapsed)
    }

    func testHttpImage() {
        let attachment = Attachment()
        attachment.imageURL = "http://rocket.chat/"
        attachment.title = "http"
        if let view = ChatMessageImageView.instantiateFromNib() {
            view.attachment = attachment
            let title = view.labelTitle?.text
            XCTAssertEqual(title, attachment.title + " (" + localized("alert.insecure_image.title") +  ")", "Should have insecurity warning")
            XCTAssertFalse(view.isLoadable)
        } else {
            XCTFail("View create failed")
        }
    }

    func testImageNoUrl() {
        let attachment = Attachment()
        attachment.title = "nil"
        if let view = ChatMessageImageView.instantiateFromNib() {
            view.attachment = attachment
            let title = view.labelTitle?.text
            XCTAssertEqual(title, "Label", "Should be default value")
        } else {
            XCTFail("View create failed")
        }
    }

    func testHttpsImage() {
        let attachment = Attachment()
        attachment.imageURL = "https://rocket.chat/"
        attachment.title = "https"
        if let view = ChatMessageImageView.instantiateFromNib() {
            view.attachment = attachment
            let title = view.labelTitle?.text
            XCTAssertEqual(title, attachment.title, "Should be regular title")
            XCTAssertEqual(ChatMessageImageView.defaultHeight, view.fullHeightConstraint.constant, "Height should not change")
            XCTAssertTrue(view.isLoadable)
        } else {
            XCTFail("View create failed")
        }
    }

    func testHttpsImageDescription() {
        let attachment = Attachment()
        attachment.imageURL = "https://rocket.chat/"
        attachment.title = "https"
        attachment.descriptionText = "I have description, that is maybe longer than one line and breaks on phones."
        if let view = ChatMessageImageView.instantiateFromNib() {
            view.attachment = attachment
            let title = view.labelTitle?.text
            XCTAssertEqual(title, attachment.title, "Should be regular title")
            XCTAssertGreaterThan(view.fullHeightConstraint.constant, ChatMessageImageView.defaultHeight)
            XCTAssertEqual(view.detailText.text, attachment.descriptionText, "Attachment with description should be higher than without")
            XCTAssertTrue(view.isLoadable)
        } else {
            XCTFail("View create failed")
        }
    }

}
