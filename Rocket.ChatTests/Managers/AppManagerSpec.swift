//
//  AppManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 10/10/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class AppManagerSpec: XCTestCase {

    func testMultiServerSupport() {
        if AppManager.applicationServerURL != nil {
            XCTAssertFalse(AppManager.supportsMultiServer, "app does not support multi-server with static server")
        } else {
            XCTAssertTrue(AppManager.supportsMultiServer, "app supports multi-server with static server")
        }
    }

    func testChangeToServerIfExists() {
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://existing.rocket.local")

        guard
            let existing = URL(string: "https://existing.rocket.local"),
            let nonExisting = URL(string: "https://nonexisting.rocket.local")
        else {
            return XCTFail("url(s) can not be nil")
        }

        XCTAssert(AppManager.changeToServerIfExists(serverUrl: existing), "changes to existing server")
        XCTAssertFalse(AppManager.changeToServerIfExists(serverUrl: nonExisting), "does not change to unexisting server")
    }

    func testReloadApp() {
        AppManager.reloadApp()
        XCTAssertNotNil(UIApplication.shared.keyWindow?.rootViewController, "reloads app correctly")
    }

    func testDeepLinkAuthNoParams() {
        guard let url = URL(string: "rocketchat://auth") else { return XCTFail("malformed url") }
        XCTAssertNil(AppManager.handleDeepLink(url))
    }

    func testDeepLinkAuthOnlyCredentials() {
        guard let url = URL(string: "rocketchat://auth?token=token&userId=userId") else { return XCTFail("malformed url") }
        XCTAssertNil(AppManager.handleDeepLink(url))
    }

    func testDeepLinkAuthOnlyHost() {
        guard let url = URL(string: "rocketchat://auth?host=open.rocket.chat") else { return XCTFail("malformed url") }
        guard let deepLink = AppManager.handleDeepLink(url) else { return XCTFail("invalid deep link") }
        guard case let .auth(host, credentials) = deepLink else { return XCTFail("deep link action is not auth") }

        XCTAssertEqual(host, "open.rocket.chat")
        XCTAssertNil(credentials)
    }

    func testDeepLinkAuthHostAndCredentials() {
        guard let url = URL(string: "rocketchat://auth?host=open.rocket.chat&token=token&userId=userId") else { return XCTFail("malformed url") }
        guard let deepLink = AppManager.handleDeepLink(url) else { return XCTFail("invalid deep link") }
        guard case let .auth(host, credentials) = deepLink else { return XCTFail("deep link action is not auth") }

        XCTAssertEqual(host, "open.rocket.chat")
        XCTAssert(credentials?.token == "token")
        XCTAssert(credentials?.userId == "userId")
    }

    func testDeepLinkRoomNoParams() {
        guard let url = URL(string: "rocketchat://room") else { return XCTFail("malformed url") }
        XCTAssertNil(AppManager.handleDeepLink(url))
    }

    func testDeepLinkRoomOnlyHost() {
        guard let url = URL(string: "rocketchat://room?host=open.rocket.chat") else { return XCTFail("malformed url") }
        XCTAssertNil(AppManager.handleDeepLink(url))
    }

    func testDeepLinkRoomOnlyRid() {
        guard let url = URL(string: "rocketchat://room?rid=rid") else { return XCTFail("malformed url") }
        XCTAssertNil(AppManager.handleDeepLink(url))
    }

    func testDeepLinkRoomHostAndRid() {
        guard let url = URL(string: "rocketchat://room?host=open.rocket.chat&rid=rid") else { return XCTFail("malformed url") }
        guard let deepLink = AppManager.handleDeepLink(url) else { return XCTFail("invalid deep link") }
        guard case let .room(host, rid) = deepLink else { return XCTFail("deep link action is not room") }

        XCTAssertEqual(host, "open.rocket.chat")
        XCTAssertEqual(rid, "rid")
    }

    func testDeepLinkMentionNoParams() {
        guard let url = URL(string: "rocketchat://mention") else { return XCTFail("malformed url") }
        XCTAssertNil(AppManager.handleDeepLink(url))
    }

    func testDeepLinkMentionName() {
        guard let url = URL(string: "rocketchat://mention?name=john.appleseed") else { return XCTFail("malformed url") }
        guard let deepLink = AppManager.handleDeepLink(url) else { return XCTFail("invalid deep link") }
        guard case let .mention(name) = deepLink else { return XCTFail("deep link action is not room") }

        XCTAssertEqual(name, "john.appleseed")
    }

    func testDeepLinkChannelNoParams() {
        guard let url = URL(string: "rocketchat://channel") else { return XCTFail("malformed url") }
        XCTAssertNil(AppManager.handleDeepLink(url))
    }

    func testDeepLinkChannelName() {
        guard let url = URL(string: "rocketchat://channel?name=general") else { return XCTFail("malformed url") }
        guard let deepLink = AppManager.handleDeepLink(url) else { return XCTFail("invalid deep link") }
        guard case let .channel(name) = deepLink else { return XCTFail("deep link action is not room") }

        XCTAssertEqual(name, "general")
    }

    func testHandleDeepLinkInvalid() {
        guard let url1 = URL(string: "rocketchat://invalid_deep_link_action") else { return XCTFail("malformed url") }
        XCTAssertNil(AppManager.handleDeepLink(url1))
    }
}
