//
//  LiveChatManagerTests.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 8/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON
@testable import RocketChat

class LiveChatManagerTests: XCTestCase {

    let socket = WebSocketMock(url: URL(string: "http://doesnt.matter")!)
    let socketManager = SDKSocketManager()

    override func setUp() {
        super.setUp()

        socket.use { json, send in
            switch json["msg"].stringValue {
            case "connect":
                send(JSON(object: ["msg": "connected"]))
            default:
                break
            }
        }

        socket.use { json, send in
            guard json["msg"].stringValue == "method" else { return }
            switch json["method"].stringValue {
            case "livechat:getInitialData":
                let data: [String: Any] = [
                    "id": json["id"].stringValue,
                    "result": [
                        "transcript": false,
                        "registrationForm": true,
                        "offlineTitle": "Leave a message (Changed)",
                        "triggers": [],
                        "displayOfflineForm": true,
                        "offlineSuccessMessage": "",
                        "departments": [
                            [
                                "_id": "sGDPYaB9i47CNRLNu",
                                "numAgents": 1,
                                "enabled": true,
                                "showOnRegistration": true,
                                "_updatedAt": [
                                    "$date": 1500709708181
                                ],
                                "description": "department description",
                                "name": "1depart"
                            ],
                            [
                                "_id": "qPYPJuL6ZPTrRrzTN",
                                "numAgents": 1,
                                "enabled": true,
                                "showOnRegistration": true,
                                "_updatedAt": [
                                    "$date": 1501163003597
                                ],
                                "description": "tech support",
                                "name": "2depart"
                            ]
                        ],
                        "offlineMessage": "localhost: We are not online right now. Please leave us a message:",
                        "title": "Rocket.Local",
                        "color": "#C1272D",
                        "room": nil,
                        "offlineUnavailableMessage": "Not available offline form",
                        "enabled": true,
                        "offlineColor": "#666666",
                        "videoCall": false,
                        "language": "",
                        "transcriptMessage": "Would you like a copy of this chat emailed?",
                        "online": false,
                        "allowSwitchingDepartments": true
                    ] as [String: Any?],
                    "msg": "result"
                ]
                send(JSON(object: data))
            default:
                break
            }
        }

        socketManager.connect(socket: socket)
        DependencyRepository.socketManager = socketManager

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testInitiate() {
        let livechatManager = LiveChatManager()
        let expect = XCTestExpectation(description: "Expect LiveChatManager initiated")
        livechatManager.initiate {
            XCTAssertTrue(livechatManager.initiated)
            XCTAssertTrue(livechatManager.enabled)
            XCTAssertTrue(livechatManager.registrationForm)
            XCTAssertEqual(livechatManager.departments.count, 2)
            expect.fulfill()
        }
    }

}
