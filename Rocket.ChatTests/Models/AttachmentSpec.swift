//
//  AttachmentSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 11/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class AttachmentSpec: XCTestCase {

    let token = "token"
    let userId = "userId"

    var auth = Auth.testInstance()

    override func setUp() {
        super.setUp()
        auth.token = token
        auth.userId = userId
    }

    func testInvalidAuth() {
        auth.token = nil
        auth.userId = nil

        let attachment = Attachment()
        attachment.titleLink = "/foo/bar"
        XCTAssertNil(attachment.fullFileURL(auth: auth)?.absoluteString, "it should return nil")
    }

    func testAttachmentFilePath() {
        let attachment = Attachment()
        attachment.titleLink = "/foo/bar"

        let resultURL = attachment.fullFileURL(auth: auth)?.absoluteString
        let expectedURL = "\(auth.baseURL() ?? "")/foo/bar?rc_uid=\(userId)&rc_token=\(token)"
        XCTAssertEqual(resultURL, expectedURL, "file url respects path")
    }

    func testAttachmentImagePath() {
        let attachment = Attachment()
        attachment.imageURL = "/foo/bar"

        let resultURL = attachment.fullImageURL(auth: auth)?.absoluteString
        let expectedURL = "\(auth.baseURL() ?? "")/foo/bar?rc_uid=\(userId)&rc_token=\(token)"
        XCTAssertEqual(resultURL, expectedURL, "image url respects path")
    }

    func testAttachmentImageURLNil() {
        let attachment = Attachment()
        attachment.imageURL = nil
        XCTAssertNil(attachment.fullImageURL(auth: auth), "image url is nil")
    }

    func testAttachmentImageURL() {
        let attachment = Attachment()
        attachment.imageURL = "https://foo.com/bar.jpeg"

        let resultURL = attachment.fullImageURL(auth: auth)?.absoluteString
        let expectedURL = "https://foo.com/bar.jpeg"
        XCTAssertEqual(resultURL, expectedURL, "image url is the same value")
    }

    func testAttachmentVideoPath() {
        let attachment = Attachment()
        attachment.videoURL = "/foo/bar"

        let resultURL = attachment.fullVideoURL(auth: auth)?.absoluteString
        let expectedURL = "\(auth.baseURL() ?? "")/foo/bar?rc_uid=\(userId)&rc_token=\(token)"
        XCTAssertEqual(resultURL, expectedURL, "video url respects path")
    }

    func testAttachmentAudioPath() {
        let attachment = Attachment()
        attachment.audioURL = "/foo/bar"

        let resultURL = attachment.fullAudioURL(auth: auth)?.absoluteString
        let expectedURL = "\(auth.baseURL() ?? "")/foo/bar?rc_uid=\(userId)&rc_token=\(token)"
        XCTAssertEqual(resultURL, expectedURL, "audio url respects path")
    }

    func testVideoThumbPathValidIdentifier() {
        let attachment = Attachment()
        attachment.identifier = "foo"

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let thumbURL = path?.appendingPathComponent("foo.png").absoluteString
        XCTAssertEqual(thumbURL, attachment.videoThumbPath?.absoluteString, "thumb path is the same")
    }

    func testVideoThumbPathEmptyIdentifier() {
        let attachment = Attachment()

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let thumbURL = path?.appendingPathComponent("temp.png").absoluteString
        XCTAssertEqual(thumbURL, attachment.videoThumbPath?.absoluteString, "thumb path name is temp")
    }

}
