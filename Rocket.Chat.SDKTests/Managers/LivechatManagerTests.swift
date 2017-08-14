//
//  LivechatManagerTests.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 8/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import RocketChat

class LivechatManagerTests: XCTestCase {

    // swiftlint:disable:next force_unwrapping
    let socket = WebSocketMock(url: URL(string: "http://doesnt.matter")!)
    let socketManager = SDKSocketManager()

    override func setUp() {
        super.setUp()

        socket.use(.connect)
        socket.use(.login)
        socket.use(.livechatInitiate)
        socket.use(.livechatRegisterGuest)
        socket.use(.livechatSendOfflineMessage)

        socketManager.connect(socket: socket)
        DependencyRepository.socketManager = socketManager

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitiate() {
        let livechatManager = LivechatManager()
        let expect = XCTestExpectation(description: "Expect LiveChatManager initiated")
        livechatManager.initiate {
            XCTAssertTrue(livechatManager.initiated)
            XCTAssertTrue(livechatManager.enabled)
            XCTAssertTrue(livechatManager.registrationForm)
            XCTAssertEqual(livechatManager.departments.count, 2)
            expect.fulfill()
        }
    }

    func testRegisterAndLogin() {
        let livechatManager = LivechatManager()
        livechatManager.initiated = true
        livechatManager.token = "YadDPc_6IfL7YJuySZ3DkOx-LSdbCtUcsypMdHVgQhx"
        let expect = XCTestExpectation(description: "Expect send offline message successfully")
        livechatManager.login {
            XCTAssertTrue(livechatManager.loggedIn)
            expect.fulfill()
        }
    }

    func testLogin() {
        let livechatManager = LivechatManager()
        livechatManager.initiated = true
        livechatManager.token = "YadDPc_6IfL7YJuySZ3DkOx-LSdbCtUcsypMdHVgQhx"
        let expect = XCTestExpectation(description: "Expect send offline message successfully")
        livechatManager.login {
            XCTAssertTrue(livechatManager.loggedIn)
            expect.fulfill()
        }
    }

    func testSendOfflineMessage() {
        let livechatManager = LivechatManager()
        let expect = XCTestExpectation(description: "Expect send offline message successfully")
        socket.use { json, _ in
            guard json["msg"].stringValue == "method" else { return }
            switch json["method"] {
            case "livechat:sendOfflineMessage":
                XCTAssertEqual(json["params"][0]["email"].stringValue, "test@example.com")
                XCTAssertEqual(json["params"][0]["name"].stringValue, "test")
                XCTAssertEqual(json["params"][0]["message"].stringValue, "test")
            default:
                break
            }
        }
        livechatManager.initiate {
            livechatManager.sendOfflineMessage(email: "test@example.com", name: "test", message: "test") {
                expect.fulfill()
            }
        }
    }

}
