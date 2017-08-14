//
//  SocketManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SocketManagerSpec: XCTestCase {

    // swiftlint:disable:next force_unwrapping
    let socket = WebSocketMock(url: URL(string: "http://doesnt.matter")!)

    override func setUp() {
        socket.use { json, send in
            switch json["msg"].stringValue {
            case "connect":
                send(JSON(object: ["msg": "connected"]))
            default:
                break
            }
        }
    }

    // MARK: SocketResponse

    func testSocketResponseErrorMethodMsgError() {
        let result = JSON(["msg": "error", "foo": "bar"])
        let response = SocketResponse(result, socket: nil)
        XCTAssert(response?.isError() == true, "isError() should return true when JSON object contains {'msg': 'error'}")
    }

    func testSocketResponseErrorObjectError() {
        let result = JSON(["msg": "result", "error": []])
        let response = SocketResponse(result, socket: nil)
        XCTAssert(response?.isError() == true, "isError() should return true when JSON object contains {'error': [...]}")
    }

    func testSocketResponseErrorFalse() {
        let result = JSON(["msg": "result", "foo": "bar", "fields": ["eventName": "event"]])
        let response = SocketResponse(result, socket: nil)
        XCTAssert(response?.isError() == false, "isError() should return true when JSON don't contains error")
    }

    func testSocketPingPong() {
        let socketManager = SocketManager()
        socketManager.connect(socket: socket)

        let expectPing = XCTestExpectation(description: "Expect event `ping`")
        let expectPong = XCTestExpectation(description: "Expect event `pong`")
        socket.use { json, send in
            switch json["msg"].stringValue {
            case "ping":
                expectPing.fulfill()
                send(JSON(object: ["msg": "ping"]))
            case "pong":
                expectPong.fulfill()
            default:
                break
            }
        }
        socketManager.send(["msg": "ping"])
        wait(for: [expectPing, expectPong], timeout: 2)
    }

    func testSendCallback() {
        let socketManager = SocketManager()
        socketManager.connect(socket: socket)

        let expectCallback = XCTestExpectation(description: "Expect callback on message response")
        socket.use { json, send in
            switch json["msg"].stringValue {
            case "foo":
                send(JSON(object: ["msg": "bar", "id": json["id"].stringValue]))
            default:
                break
            }
        }
        socketManager.send(["msg": "foo"]) { response in
            XCTAssertEqual(response.result["msg"].stringValue, "bar")
            expectCallback.fulfill()
        }
        wait(for: [expectCallback], timeout: 2)
    }

    func testSubscribe() {
        let socketManager = SocketManager()
        socketManager.connect(socket: socket)

        let expectCallback = XCTestExpectation(description: "Expect full events subscription")
        socket.use { json, send in
            switch json["msg"].stringValue {
            case "subscribe":
                send(JSON(object: ["msg": ""]))
                4.times { idx in
                    send(JSON(object: [
                        "msg": "updated",
                        "id": json["id"].stringValue,
                        "fields": [
                            "eventName": "foo",
                            "time": idx
                        ]
                    ]))
                }
            default:
                break
            }
        }
        var count = 0
        socketManager.subscribe(["msg": "subscribe"], eventName: "foo") { response in
            XCTAssertEqual(response.event, "foo")
            count += response.result["fields"]["time"].intValue
            if count == 10 {
                expectCallback.fulfill()
            }
        }
        wait(for: [expectCallback], timeout: 2)
    }

}
