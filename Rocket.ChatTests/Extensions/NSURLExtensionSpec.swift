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
            "http://demo.rocket.chat/",
            "wss://demo.rocket.chat/",
            "wss://demo.rocket.chat/websocket",
            "ftp://foo.bar.websocket.foo/chat/",
            "http://foo/websocket",
            "http://127.0.0.1/websocket"
        ]
        
        for test in tests {
            let url = NSURL(string: test)
            let socketURL = url?.socketURL()
            
            XCTAssertEqual(socketURL?.scheme, "wss")
            XCTAssertTrue(socketURL?.pathComponents?.contains("websocket") ?? false)
        }
    }
    
}