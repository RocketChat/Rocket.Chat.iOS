//
//  FileSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 14/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

final class FileSpec: XCTestCase {

    func testFileImageExtensions() {
        let extensions = [
            "image/bmp",
            "image/cis-cod",
            "image/gif",
            "image/ief",
            "image/jpeg",
            "image/pipeg",
            "image/svg+xml",
            "image/tiff",
            "image/x-cmu-raster",
            "image/x-cmx",
            "image/x-icon",
            "image/x-portable-anymap",
            "image/x-portable-bitmap",
            "image/x-portable-graymap",
            "image/x-portable-pixmap",
            "image/x-rgb",
            "image/x-xbitmap",
            "image/x-xpixmap",
            "image/x-xwindowdump"
        ]

        let file = File()
        extensions.forEach({
            file.type = $0
            XCTAssertTrue(file.isImage)
        })
    }

    func testFileGIFExtensions() {
        let file = File()
        file.type = "image/gif"
        XCTAssertTrue(file.isGif)
    }

    func testFileVideoExtensions() {
        let extensions = [
            "video/mpeg",
            "video/mp4",
            "video/quicktime",
            "video/x-la-asf",
            "video/x-ms-asf",
            "video/x-msvideo",
            "video/x-sgi-movie"
        ]

        let file = File()
        extensions.forEach({
            file.type = $0
            XCTAssertTrue(file.isVideo)
        })
    }

    func testFileAudioExtensions() {
        let extensions = [
            "audio/basic",
            "audio/mid",
            "audio/mpeg",
            "audio/mp3",
            "audio/mp4",
            "audio/x-aiff",
            "audio/x-mpegurl",
            "audio/x-pn-realaudio",
            "audio/x-wav"
        ]

        let file = File()
        extensions.forEach({
            file.type = $0
            XCTAssertTrue(file.isAudio)
        })
    }

}
