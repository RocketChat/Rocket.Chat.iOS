//
//  SettingsViewModelTests.swift
//  Rocket.Chat
//
//  Created by Rafael Ramos on 31/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class SettingsViewModelTests: XCTestCase {

    let info = Bundle.main.infoDictionary
    let model = SettingsViewModel()

    func testAppVersion() {
        let version = info?["CFBundleShortVersionString"] as? String
        XCTAssert(model.version == version, "Show app version")
    }

    func testBuildVersion() {
        let build = info?["CFBundleVersion"] as? String
        XCTAssert(model.build == build, "Show build version")
    }

    func testFormattedAppVersion() {
        let build = info?["CFBundleVersion"] as? String ?? ""
        let version = info?["CFBundleShortVersionString"] as? String ?? ""
        let formatted = "Version: \(version) (\(build))"

        XCTAssert(model.formattedVersion == formatted, "Show app version and build")
    }

    func testRocketChatURL() {
        let url = URL(string: "https://rocket.chat")
        let modelURL = model.settingsURL(atIndex: 0)?.absoluteString
        XCTAssert(modelURL == url?.absoluteString, "Show rocketchat website url")
    }

    func testContactURL() {
        let url = URL(string: "https://rocket.chat/contact")
        let modelURL = model.settingsURL(atIndex: 1)?.absoluteString
        XCTAssert(modelURL == url?.absoluteString, "Show contact url")
    }

    func testLicenseURL() {
        let url = URL(string: "https://github.com/RocketChat/Rocket.Chat.iOS/blob/develop/LICENSE")
        let modelURL = model.settingsURL(atIndex: 2)?.absoluteString
        XCTAssert(modelURL == url?.absoluteString, "Show contact url")
    }

    func testInvalidSectino() {
        let modelURL = model.settingsURL(atIndex: 3)?.absoluteString
        XCTAssert(modelURL == nil, "Section 3 is invalid, no data in here so far")
    }
}
