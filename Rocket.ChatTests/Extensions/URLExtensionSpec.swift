//
//  URLExtensionSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/27/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class URLExtensionSpec: XCTestCase {

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
        XCTAssertEqual(URL(string: "open.rocket.chat:3000", scheme: "https")?.absoluteString, "https://open.rocket.chat:3000", "will add scheme & keep port")
        XCTAssertEqual(URL(string: "https://open.rocket.chat", scheme: "https")?.absoluteString, "https://open.rocket.chat", "will return correct url")
        XCTAssertEqual(URL(string: "https://open.rocket.chat:3000", scheme: "https")?.absoluteString, "https://open.rocket.chat:3000", "will return correct url & port")
        XCTAssertEqual(URL(string: "http://open.rocket.chat", scheme: "https")?.absoluteString, "https://open.rocket.chat", "will force https scheme")
        XCTAssertEqual(URL(string: "https://open.rocket.chat", scheme: "wss")?.absoluteString, "wss://open.rocket.chat", "will force wss scheme")
        XCTAssertEqual(URL(string: "http://open.rocket.chat/path", scheme: "https")?.absoluteString, "https://open.rocket.chat/path", "will keep path")
        XCTAssertEqual(URL(string: "http://open.rocket.chat?query=test", scheme: "https")?.absoluteString, "https://open.rocket.chat?query=test", "will keep query")
        XCTAssertEqual(URL(string: "http://open.rocket.chat/path?query=test", scheme: "https")?.absoluteString, "https://open.rocket.chat/path?query=test", "will keep path & query")
        XCTAssertEqual(URL(string: "http://open.rocket.chat:3000/path?query=test", scheme: "https")?.absoluteString, "https://open.rocket.chat:3000/path?query=test", "will keep path & query & port")
        XCTAssertNil(URL(string: "http://", scheme: "https")?.absoluteString, "will return nil when hostless")
        XCTAssertNil(URL(string: "", scheme: "https"), "will return nil when empty")
    }

    func testQueryParameters() {
        let testURL: URL! = URL(string: "https://open.rocket.chat/?query1=test1&query2=test2")

        guard let queryParameters = testURL.queryParameters else {
            XCTFail("queryParameters is not nil")
            return
        }

        XCTAssertEqual(queryParameters, ["query1": "test1", "query2": "test2"], "queryParameters returns dictionary correctly")

        let testURL2: URL! = URL(string: "https://open.rocket.chat/")

        XCTAssertNil(testURL2.queryParameters, "queryParameters is nil when there are no queries")
    }

    func testRemoveDuplicatedSlashes() {
        guard
            let urlNormal = URL(string: "https://foo.com/bar/foo/baz"),
            let urlDuplicated = URL(string: "https://foo.com//bar//foo//baz//"),
            let urlDuplicatedQueries = URL(string: "https://foo.com//bar//foo//baz//?foo=bar&baz=yay")
        else {
            return XCTFail("urls are not valid")
        }

        XCTAssertEqual(urlNormal.removingDuplicatedSlashes()?.absoluteString, "https://foo.com/bar/foo/baz")
        XCTAssertEqual(urlDuplicated.removingDuplicatedSlashes()?.absoluteString, "https://foo.com/bar/foo/baz/")
        XCTAssertEqual(urlDuplicatedQueries.removingDuplicatedSlashes()?.absoluteString, "https://foo.com/bar/foo/baz/?foo=bar&baz=yay")
    }
}
