//
//  DownloadManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/08/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class DownloadManagerSpec: XCTestCase {

    func testFilenameForURL() {
        let url = "http://foo.bar/filename.png"

        guard let filename = DownloadManager.filenameFor(url) else {
            return XCTAssertTrue(false, "filename is invalid")
        }

        XCTAssertEqual(filename, "filename.png", "filename is the same as URL")
    }

}
