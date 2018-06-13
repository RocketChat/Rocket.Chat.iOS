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
        UserDefaults.group.set(["en"], forKey: "AppleLanguages")
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

    func testTrackingValue() {
        let value = BugTrackingCoordinator.isCrashReportingDisabled

        // trackinValue is always the opposite of the value
        XCTAssertNotEqual(model.trackingValue, value)
    }

    func testNumberOfRowsInSection() {
        XCTAssertEqual(model.numberOfSections, 7)
        XCTAssertEqual(model.numberOfRowsInSection(0), 1)
        XCTAssertEqual(model.numberOfRowsInSection(1), 4)
        XCTAssertEqual(model.numberOfRowsInSection(2), 1)
        XCTAssertEqual(model.numberOfRowsInSection(3), 3)
        XCTAssertEqual(model.numberOfRowsInSection(4), 1)
        XCTAssertEqual(model.numberOfRowsInSection(5), 1)
        XCTAssertEqual(model.numberOfRowsInSection(6), 1)
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

        XCTAssertNotNil(model.webBrowser)
        XCTAssertNotEqual(model.webBrowser, "")

        XCTAssertNotNil(model.trackingTitle)
        XCTAssertNotEqual(model.trackingTitle, "")

        XCTAssertNotNil(model.trackingFooterText)
        XCTAssertNotEqual(model.trackingFooterText, "")
    }

}
