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

    func testTitleLinkDownloadTrue() {
        let attachment = Attachment()
        attachment.map([
            "title_link_download": true,
            "title_link": "http://foo.bar/file.jpeg"
        ], realm: nil)

        XCTAssertTrue(attachment.titleLinkDownload, "titleLink isn't downloadable")
    }

    func testTitleLinkDownloadFalse() {
        let attachment = Attachment()
        attachment.map([
            "title_link_download": false,
            "title_link": "http://foo.bar/file.jpeg"
        ], realm: nil)

        XCTAssertFalse(attachment.titleLinkDownload, "titleLink isn't downloadable")
    }

    func testAttachmentFilePath() {
        let attachment = Attachment()
        attachment.titleLink = "/foo/bar"

        let resultURL = attachment.fullFileURL(auth: auth)?.absoluteString
        let expectedURL = "\(auth.baseURL() ?? "")/foo/bar?rc_uid=\(userId)&rc_token=\(token)"
        XCTAssertEqual(resultURL, expectedURL, "file url respects path")
    }

    func testAttachmentFileURL() {
        let attachment = Attachment()
        attachment.titleLink = "https://foo.com/title.link"

        let resultURL = attachment.fullFileURL(auth: auth)?.absoluteString
        let expectedURL = "https://foo.com/title.link"
        XCTAssertEqual(resultURL, expectedURL, "file url is the same value")
    }

    func testAttachmentFileURLEmpty() {
        let attachment = Attachment()
        attachment.titleLink = ""

        let result = attachment.fullFileURL(auth: auth)?.absoluteString
        XCTAssertEqual(result, "https://open.rocket.chat?rc_uid=userId&rc_token=token", "file url is not nil")
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

    func testAttachmentVideoURL() {
        let attachment = Attachment()
        attachment.videoURL = "https://foo.com/video.url"

        let resultURL = attachment.fullVideoURL(auth: auth)?.absoluteString
        let expectedURL = "https://foo.com/video.url"
        XCTAssertEqual(resultURL, expectedURL, "video url is the same value")
    }

    func testAttachmentVideoURLNil() {
        let attachment = Attachment()
        attachment.videoURL = nil
        XCTAssertNil(attachment.fullVideoURL(auth: auth), "video url is nil")
    }

    func testAttachmentAudioPath() {
        let attachment = Attachment()
        attachment.audioURL = "/foo/bar"

        let resultURL = attachment.fullAudioURL(auth: auth)?.absoluteString
        let expectedURL = "\(auth.baseURL() ?? "")/foo/bar?rc_uid=\(userId)&rc_token=\(token)"
        XCTAssertEqual(resultURL, expectedURL, "audio url respects path")
    }

    func testAttachmentAudioURL() {
        let attachment = Attachment()
        attachment.audioURL = "https://foo.com/audio.url"

        let resultURL = attachment.fullAudioURL(auth: auth)?.absoluteString
        let expectedURL = "https://foo.com/audio.url"
        XCTAssertEqual(resultURL, expectedURL, "audio url is the same value")
    }

    func testAttachmentAudioURLNil() {
        let attachment = Attachment()
        attachment.audioURL = nil
        XCTAssertNil(attachment.fullAudioURL(auth: auth), "audio url is nil")
    }

    func testVideoThumbPathValidIdentifier() {
        let attachment = Attachment()
        attachment.videoURL = "/foo/bar"

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let thumbURL = path?.appendingPathComponent("\\foo\\bar.png").absoluteString
        XCTAssertEqual(thumbURL, attachment.videoThumbPath?.absoluteString, "thumb path is the same")
    }

    func testVideoThumbPathEmptyIdentifier() {
        let attachment = Attachment()

        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        let thumbURL = path?.appendingPathComponent("temp.png").absoluteString
        XCTAssertEqual(thumbURL, attachment.videoThumbPath?.absoluteString, "thumb path name is temp")
    }

}
