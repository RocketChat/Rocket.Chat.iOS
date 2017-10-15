//
//  NSURLExtensionSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/27/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class NSURLExtensionSpec: XCTestCase {

    func testSocketURLComponents() {
        let tests = [
            "http://open.rocket.chat/",
            "wss://open.rocket.chat/",
            "wss://open.rocket.chat/websocket",
            "ftp://foo.bar.websocket.foo/chat/",
            "http://foo/websocket",
            "http://127.0.0.1/websocket"
        ]

        for test in tests {
            let url = URL(string: test)
            let socketURL = url?.socketURL()

            XCTAssertEqual(socketURL?.scheme, "wss")
            XCTAssertTrue(socketURL?.pathComponents.contains("websocket") ?? false)
        }
    }

    func testInitWithStringAndScheme() {
        XCTAssertEqual(URL(string: "open.rocket.chat", scheme: "https")?.absoluteString, "https://open.rocket.chat", "will add scheme")
        XCTAssertEqual(URL(string: "https://open.rocket.chat", scheme: "https")?.absoluteString, "https://open.rocket.chat", "will return correct url")
        XCTAssertEqual(URL(string: "http://open.rocket.chat", scheme: "https")?.absoluteString, "https://open.rocket.chat", "will force https scheme")
        XCTAssertEqual(URL(string: "https://open.rocket.chat", scheme: "wss")?.absoluteString, "wss://open.rocket.chat", "will force wss scheme")
        XCTAssertEqual(URL(string: "http://open.rocket.chat/path", scheme: "https")?.absoluteString, "https://open.rocket.chat/path", "will keep path")
        XCTAssertEqual(URL(string: "http://open.rocket.chat?query=test", scheme: "https")?.absoluteString, "https://open.rocket.chat?query=test", "will keep query")
        XCTAssertEqual(URL(string: "http://open.rocket.chat/path?query=test", scheme: "https")?.absoluteString, "https://open.rocket.chat/path?query=test", "will keep path & query")
        XCTAssertNil(URL(string: "http://", scheme: "https")?.absoluteString, "will return nil when hostless")
        XCTAssertNil(URL(string: "", scheme: "https"), "will return nil when empty")
    }
}
