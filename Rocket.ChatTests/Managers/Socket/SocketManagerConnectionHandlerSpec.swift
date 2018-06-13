//
//  SocketManagerConnectionHandlerSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 12/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class TestSocketConnectionHandler: SocketConnectionHandler {

    var state: SocketConnectionState = .disconnected

    func socketDidChangeState(state: SocketConnectionState) {
        self.state = state
    }
}

class SocketManagerConnectionHandlerSpec: XCTestCase {

    let connectionHandlerToken = "socketmanager-handler"

    func testSocketStateHasChangedNotification() {
        let instance = TestSocketConnectionHandler()

        SocketManager.addConnectionHandler(token: connectionHandlerToken, handler: instance)

        SocketManager.sharedInstance.state = .connected
        XCTAssertEqual(instance.state, .connected)

        SocketManager.sharedInstance.state = .disconnected
        XCTAssertEqual(instance.state, .disconnected)

        SocketManager.sharedInstance.state = .waitingForNetwork
        XCTAssertEqual(instance.state, .waitingForNetwork)

        SocketManager.sharedInstance.state = .connecting
        XCTAssertEqual(instance.state, .connecting)
    }

    func testSocketStateHasNotChangedNotificationOnRemovingHandler() {
        let instance = TestSocketConnectionHandler()

        SocketManager.addConnectionHandler(token: connectionHandlerToken, handler: instance)

        SocketManager.sharedInstance.state = .connected
        XCTAssertEqual(instance.state, .connected)

        SocketManager.removeConnectionHandler(token: connectionHandlerToken)

        SocketManager.sharedInstance.state = .disconnected
        XCTAssertNotEqual(instance.state, .disconnected)
        XCTAssertEqual(instance.state, .connected)
    }

    func testSocketStateHasNotChangedNotificationOnRemovingAllHandlers() {
        let instance = TestSocketConnectionHandler()

        SocketManager.addConnectionHandler(token: connectionHandlerToken, handler: instance)

        SocketManager.sharedInstance.state = .connected
        XCTAssertEqual(instance.state, .connected)

        SocketManager.sharedInstance.connectionHandlers.removeAllObjects()

        SocketManager.sharedInstance.state = .disconnected
        XCTAssertNotEqual(instance.state, .disconnected)
        XCTAssertEqual(instance.state, .connected)
    }

    func testSocketStateHasNotChangedNotificationOnNotAddingHandler() {
        let instance = TestSocketConnectionHandler()

        SocketManager.sharedInstance.state = .connected
        XCTAssertNotEqual(instance.state, .connected)
        XCTAssertEqual(instance.state, .disconnected)
    }

}
