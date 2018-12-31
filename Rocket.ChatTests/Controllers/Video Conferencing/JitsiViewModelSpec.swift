//
//  JitsiViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Streit on 27/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

import XCTest
@testable import Rocket_Chat

final class JitsiViewModelSpec: XCTestCase {

    func testInitialState() {
        let model = JitsiViewModel()
        XCTAssertNil(model.subscription)
        XCTAssertNil(model.user)
        XCTAssertEqual(model.userDisplayName, "")
        XCTAssertEqual(model.userAvatar, "")
        XCTAssertEqual(model.videoCallURL, "")
    }

    func testSubscriptionURLNotEmpty() {
        let subscription = Subscription()
        subscription.identifier = "identifier"
        subscription.rid = "123abc"

        let settings = AuthSettings()
        settings.isJitsiEnabled = true
        settings.isJitsiSSL = true
        settings.jitsiDomain = "rocket.chat"
        settings.jitsiPrefix = "RocketChat"

        AuthSettingsManager.shared.internalSettings = settings

        let model = JitsiViewModel()
        model.subscription = UnmanagedSubscription(subscription)

        XCTAssertEqual(model.videoCallURL, "https://rocket.chat/RocketChatundefined123abc")
    }

    func testSubscriptionURLWithUniqueIDSettingNotEmpty() {
        let subscription = Subscription()
        subscription.identifier = "identifier"
        subscription.rid = "123abc"

        let settings = AuthSettings()
        settings.isJitsiEnabled = true
        settings.isJitsiSSL = true
        settings.jitsiDomain = "rocket.chat"
        settings.jitsiPrefix = "RocketChat"
        settings.uniqueIdentifier = "uniqueIdentifier"

        AuthSettingsManager.shared.internalSettings = settings

        let model = JitsiViewModel()
        model.subscription = UnmanagedSubscription(subscription)

        XCTAssertEqual(model.videoCallURL, "https://rocket.chat/RocketChatuniqueIdentifier123abc")
    }

}
