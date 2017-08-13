//
//  LivechatSubscriptionManagerTests.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 8/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
@testable import RocketChat

class LivechatSubscriptionManagerTests: XCTestCase {
    
    let socket = WebSocketMock(url: URL(string: "http://doesnt.matter")!)
    let socketManager = SDKSocketManager()

    override func setUp() {
        super.setUp()

        socket.use(.connect)
        socket.use(.livechatSendMessage)

        socketManager.connect(socket: socket)
        DependencyRepository.socketManager = socketManager
        DependencyRepository.livechatManager.visitorToken = "YadDPc_6IfL7YJuySZ3DkOx-LSdbCtUcsypMdHVgQhx"

        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }

    func testSendLivechatMessage() {
        let subscriptionManager = LivechatSubscriptionManager()

        let roomSubscription = Subscription()
        roomSubscription.identifier = UUID().uuidString
        roomSubscription.rid = String.random()
        roomSubscription.name = "TestDepartment"
        roomSubscription.type = .livechat

        let message = Message()
        message.internalType = ""
        message.createdAt = Date()
        message.text = "Test"
        message.identifier = UUID().uuidString
        message.subscription = roomSubscription
        message.temporary = true

        let realm = try? Realm()
        try? realm?.write {
            realm?.add(roomSubscription)
            realm?.add(message)
        }
        let expect = XCTestExpectation(description: "Expect send message successfully")
        subscriptionManager.sendTextMessage(message) { _ in
            expect.fulfill()
        }
    }

}
