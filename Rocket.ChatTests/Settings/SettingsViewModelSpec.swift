//
//  SettingsViewModelSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Ramos on 31/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class SettingsViewModelSpec: XCTestCase {

    let info = Bundle.main.infoDictionary
    let model = SettingsViewModel()

    func testAppVersion() {
        let version = info?["CFBundleShortVersionString"] as? String
        XCTAssert(model.version == version, "show app version")
    }

    func testBuildVersion() {
        let build = info?["CFBundleVersion"] as? String
        XCTAssert(model.build == build, "show build version")
    }

    func testFormattedAppVersion() {
        let build = info?["CFBundleVersion"] as? String ?? ""
        let version = info?["CFBundleShortVersionString"] as? String ?? ""
        let formatted = "Version: \(version) (\(build))"

        XCTAssert(model.formattedVersion == formatted, "show app version and build")
    }

    func testLicenseURL() {
        let url = URL(string: "https://github.com/RocketChat/Rocket.Chat.iOS/blob/develop/LICENSE")
        let modelURL = model.licenseURL
        XCTAssert(modelURL?.absoluteString == url?.absoluteString, "show license url")
    }

    func testLicenseURLNotNit() {
        XCTAssertNotNil(model.licenseURL, "license URL is not nil")
    }

    func testStringsOverall() {
        XCTAssertNotNil(model.title)
        XCTAssertNotEqual(model.title, "")

        XCTAssertNotNil(model.contactus)
        XCTAssertNotEqual(model.contactus, "")

        XCTAssertNotNil(model.license)
        XCTAssertNotEqual(model.license, "")

        XCTAssertNotNil(model.supportEmail)
        XCTAssertNotEqual(model.supportEmail, "")

        XCTAssertNotNil(model.supportEmailBody)
        XCTAssertNotEqual(model.supportEmailBody, "")

        XCTAssertNotNil(model.supportEmailSubject)
        XCTAssertNotEqual(model.supportEmailSubject, "")
    }

}
