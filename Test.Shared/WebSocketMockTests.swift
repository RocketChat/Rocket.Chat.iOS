//
//  WebSocketMockTests.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 8/6/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import Rocket_Chat

class WebSocketMockTests: XCTestCase {

    func testWebSocketMock() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let socket = WebSocketMock(url: URL(string: "http://doesnt.matter")!)
        socket.onTextReceived = { _, send in
            send(JSON(stringLiteral: "Hello"))
        }

        let expectOnConnect = XCTestExpectation(description: "Expect `onConnect` being called")
        socket.onConnect = {
            XCTAssertTrue(socket.isConnected)
            expectOnConnect.fulfill()
        }
        socket.connect()
        wait(for: [expectOnConnect], timeout: 1)

        let expectOnText = XCTestExpectation(description: "Expect `onText` being called")
        socket.onText = { (text) in
            XCTAssertEqual(text, "Hello")
            expectOnText.fulfill()
        }
        socket.write(string: "ping text")
        wait(for: [expectOnText], timeout: 1)

        let expectOnDisconnect = XCTestExpectation(description: "Expect `onDisconnect` being called")
        socket.onDisconnect = { _ in
            XCTAssertFalse(socket.isConnected)
            expectOnDisconnect.fulfill()
        }
        socket.disconnect()
        wait(for: [expectOnDisconnect], timeout: 1)
    }

    func testWithSocketManager() {
        let socketManager = SocketManager()
        let socket = WebSocketMock(url: URL(string: "http://doesnt.matter")!)

        let expectOnConnect = XCTestExpectation(description: "Expect `onConnect` being called")
        let expectReceivedConnect = XCTestExpectation(description: "Expect receiving `connect` event")
        socket.onJSONReceived = { json, send in
            switch json["msg"].stringValue {
            case "connect":
                expectReceivedConnect.fulfill()
                send(JSON(object: ["msg": "connected"]))
            default:
                return
            }
        }
        socketManager.connect(socket: socket) { _, connected in
            XCTAssertTrue(connected)
            expectOnConnect.fulfill()
        }
        wait(for: [expectOnConnect, expectReceivedConnect], timeout: 1)
    }

}
