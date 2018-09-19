//
//  UploadHelperSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class UploadHelperSpec: XCTestCase {

    func testFileUploadObject() {
        let name = "foo.png"
        let mimetype = "image/png"

        guard
            let image = UIImage(named: "logoSmall"),
            let data = image.pngData()
        else {
            return XCTAssertTrue(false, "File wasn't created successfuly")
        }

        let file = UploadHelper.file(for: data, name: name, mimeType: mimetype)

        XCTAssert(file.name == name, "file name is equal to name")
        XCTAssert(file.type == mimetype, "file type is equal to mimetype")
        XCTAssert(file.data == data, "file data is equal to data")
        XCTAssert(file.size == (data as NSData).length, "file data is equal to data")
    }

    func testFileMimetype() {
        let files: [String: String] = [
            "filename.png": "image/png",
            "filename.jpg": "image/jpeg",
            "filename.jpeg": "image/jpeg",
            "filename.pdf": "application/pdf",
            "filename.mp4": "video/mp4"
        ]

        for file in files.keys {
            if let localURL = DownloadManager.localFileURLFor(file) {
                let mimetype = UploadHelper.mimeTypeFor(localURL)
                XCTAssert(mimetype == files[file], "\(file) mimetype (\(mimetype)) respects the extension")
            } else {
                XCTAssertTrue(false, "file url is invalid")
            }
        }
    }

    func testFileSize() {
        guard
            let image = UIImage(named: "logoSmall"),
            let data = image.pngData()
        else {
            return XCTAssertTrue(false, "File data isn't valid")
        }

        XCTAssert(UploadHelper.sizeFor(data) == (data as NSData).length, "file data is equal to data")
    }

    func testFileName() {
        let filename = "filename.png"

        guard let localURL = DownloadManager.localFileURLFor(filename) else {
            return XCTAssertTrue(false, "file url is invalid")
        }

        XCTAssert(filename == UploadHelper.nameFor(localURL), "filename keeps the same after URL")
    }

}
