//
//  Version.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class VersionSpec: XCTestCase {
    func testString() {
        let string = "11.22.33-identifier+metadata.0"

        let invalid = "1.invalid."
        let simple = "0.60.3"

        guard let version = Version(string), let versionSimple = Version(simple) else {
            return XCTFail("string can be converted to version")
        }

        XCTAssertEqual("\(version)", string)

        XCTAssertEqual(version.major, 11)
        XCTAssertEqual(version.minor, 22)
        XCTAssertEqual(version.patch, 33)
        XCTAssertEqual(version.identifier, "identifier")
        XCTAssertEqual(version.metadata, "metadata.0")

        XCTAssertEqual(versionSimple.major, 0)
        XCTAssertEqual(versionSimple.minor, 60)
        XCTAssertEqual(versionSimple.patch, 3)
        XCTAssertNil(versionSimple.identifier)
        XCTAssertNil(versionSimple.metadata)

        XCTAssertNil(Version(invalid))
    }

    func testComparable() {
        var version1 = Version(major: 0, minor: 1, patch: 2)
        var version2 = Version(major: 2, minor: 1, patch: 0)

        XCTAssert(version2 > version1)

        version1 = Version(major: 0, minor: 1, patch: 2)
        version2 = Version(major: 0, minor: 2, patch: 1)

        XCTAssert(version2 > version1)

        version1 = Version(major: 2, minor: 1, patch: 0)
        version2 = Version(major: 0, minor: 1, patch: 2)

        XCTAssert(version2 > version1)
    }
}
