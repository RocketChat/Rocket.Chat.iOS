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
        // swiftlint:disable:next force_unwrapping
        let socket = WebSocketMock(url: URL(string: "http://doesnt.matter")!)
        socket.use { _, send in
            send(JSON(stringLiteral: "Hello"))
        }

        let expectOnConnect = XCTestExpectation(description: "Expect `onConnect` being called")
        socket.onConnect = {
            XCTAssertTrue(socket.isConnected)
            expectOnConnect.fulfill()
        }
        socket.connect()
        wait(for: [expectOnConnect], timeout: 2)

        let expectOnText = XCTestExpectation(description: "Expect `onText` being called")
        socket.onText = { (text) in
            XCTAssertEqual(text, "Hello")
            expectOnText.fulfill()
        }
        socket.write(string: "ping text")
        wait(for: [expectOnText], timeout: 2)

        let expectOnDisconnect = XCTestExpectation(description: "Expect `onDisconnect` being called")
        socket.onDisconnect = { _ in
            XCTAssertFalse(socket.isConnected)
            expectOnDisconnect.fulfill()
        }
        socket.disconnect()
        wait(for: [expectOnDisconnect], timeout: 2)
    }

    func testWithSocketManager() {
        let socketManager = SocketManager()
        // swiftlint:disable:next force_unwrapping
        let socket = WebSocketMock(url: URL(string: "http://doesnt.matter")!)

        // Connect
        let expectOnConnect = XCTestExpectation(description: "Expect `onConnect` being called")
        let expectReceivedConnect = XCTestExpectation(description: "Expect receiving `connect` event")
        socket.use { json, send in
            switch json["msg"].stringValue {
            case "connect":
                expectReceivedConnect.fulfill()
                send(JSON(object: ["msg": "connected"]))
            default:
                break
            }
        }
        socketManager.connect(socket: socket) { _, connected in
            XCTAssertTrue(connected)
            expectOnConnect.fulfill()
        }
        wait(for: [expectOnConnect, expectReceivedConnect], timeout: 2)
        socketManager.clear()

        // Event Cascading in WebSocketMock
        let expectEventCascading = XCTestExpectation(description: "Expect event cascading")
        socket.use { json, send in
            switch json["msg"].stringValue {
            case "mock":
                XCTAssertEqual(json["mock"].stringValue, "EventCascading")
                expectEventCascading.fulfill()
                send(JSON(object: ["msg": "mocked"]))
            default:
                break
            }
        }
        socketManager.send(["msg": "mock", "mock": "EventCascading"])
        wait(for: [expectEventCascading], timeout: 2)

        // Disconnect
        let expectOnDidconnect = XCTestExpectation(description: "Expect `onDisconnect` being called")
        let expectDisconnectEvent = XCTestExpectation(description: "Expect `internalConnectionHandler` being called if disconnected")
        socket.onDisconnect = { _ in
            expectOnDidconnect.fulfill()
        }
        socketManager.disconnect { _, connected in
            XCTAssertFalse(connected)
            expectDisconnectEvent.fulfill()
        }
        wait(for: [expectOnDidconnect, expectDisconnectEvent], timeout: 2)
    }

    func testConnectionInterruption() {
        let socketManager = SocketManager()
        // swiftlint:disable:next force_unwrapping
        let socket = WebSocketMock(url: URL(string: "http://doesnt.matter")!)

        // Connect
        let expectOnConnect = XCTestExpectation(description: "Expect `onConnect` being called")
        let expectReceivedConnect = XCTestExpectation(description: "Expect receiving `connect` event")
        socket.use { json, send in
            switch json["msg"].stringValue {
            case "connect":
                expectReceivedConnect.fulfill()
                send(JSON(object: ["msg": "connected"]))
            default:
                break
            }
        }
        socketManager.connect(socket: socket) { _, connected in
            XCTAssertTrue(connected)
            expectOnConnect.fulfill()
        }
        wait(for: [expectOnConnect, expectReceivedConnect], timeout: 2)
        socketManager.clear()

        // Connection Interruption
        let expectOnConnectionInterrupted = XCTestExpectation(description: "Expect connection interruptted")
        socketManager.internalConnectionHandler = { _, connected in
            XCTAssertFalse(connected)
            expectOnConnectionInterrupted.fulfill()
        }
        socket.disconnect()
        wait(for: [expectOnConnectionInterrupted], timeout: 2)
    }

}
