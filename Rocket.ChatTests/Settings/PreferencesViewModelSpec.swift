//
//  PreferencesViewModelSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Ramos on 31/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class PreferencesViewModelSpec: XCTestCase {

    let info = Bundle.main.infoDictionary
    let model = PreferencesViewModel()

    override func setUp() {
        super.setUp()
        UserDefaults.standard.set(["en"], forKey: "AppleLanguages")
    }

    func testAppVersion() {
        let version = info?["CFBundleShortVersionString"] as? String
        XCTAssertEqual(model.version, version, "show app version")
    }

    func testBuildVersion() {
        let build = info?["CFBundleVersion"] as? String
        XCTAssertEqual(model.build, build, "show build version")
    }

    func testFormattedAppVersion() {
        let build = info?["CFBundleVersion"] as? String ?? ""
        let version = info?["CFBundleShortVersionString"] as? String ?? ""
        let formatted = "Version: \(version) (\(build))"

        XCTAssertEqual(model.formattedVersion, formatted, "show app version and build")
    }

    func testLicenseURL() {
        let url = URL(string: "https://github.com/RocketChat/Rocket.Chat.iOS/blob/develop/LICENSE")
        let modelURL = model.licenseURL
        XCTAssertEqual(modelURL?.absoluteString, url?.absoluteString, "show license url")
    }

    func testLicenseURLNotNit() {
        XCTAssertNotNil(model.licenseURL, "license URL is not nil")
    }

    func testCanChangeAppIcon() {
        // Since we are running tests on iOS 10.3 it should always return true
        XCTAssertTrue(model.canChangeAppIcon, "invalid value for canChangeAppIcon")
    }

    func testNumberOfRowsInSection() {
        XCTAssertTrue(model.numberOfSections == 3, "incorrect sections number")
        XCTAssertTrue(model.numberOfRowsInSection(0) == 3, "incorrect rows number")
        XCTAssertTrue(model.numberOfRowsInSection(1) == 2, "incorrect rows number")
        XCTAssertTrue(model.numberOfRowsInSection(2) == 1, "incorrect rows number")
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

        XCTAssertNotNil(model.appicon)
        XCTAssertNotEqual(model.appicon, "")
    }

}
