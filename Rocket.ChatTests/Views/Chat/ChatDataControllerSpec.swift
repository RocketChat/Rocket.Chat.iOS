//
//  ChatDataControllerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 24/04/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
@testable import Rocket_Chat

class ChatDataControllerSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        Realm.execute({ realm in
            for obj in realm.objects(Message.self) {
                realm.delete(obj)
            }
        })
    }

    func testInitilization() {
        let controller = ChatDataController()
        XCTAssertEqual(controller.data.count, 0, "Controller has no data on initialization")
    }

    func testInsertObject() {
        let controller = ChatDataController()

        var message: Message!
        Realm.executeOnMainThread { (realm) in
            message = Message()
            message.identifier = "123"
            message.text = "Foobar"
            realm.add(message)
        }

        XCTAssertNotNil(message, "Message can't be nil")

        var obj = ChatData(type: .message, timestamp: Date())
        obj?.message = message
        XCTAssertNotNil(obj, "obj can't be nil")

        if let obj = obj {
            let indexPaths = controller.insert([obj])
            XCTAssertNotNil(indexPaths, "indexPaths can't be nil")
            XCTAssertEqual(indexPaths.count, 1, "indexPaths will have one result")
        }
    }

    func testInsertMultipleObjects() {
        let controller = ChatDataController()

        var message1: Message!
        var message2: Message!
        Realm.executeOnMainThread { (realm) in
            message1 = Message()
            message1.identifier = "test-multiple-1"
            message1.text = "Foobar 1"
            realm.add(message1)

            message2 = Message()
            message2.identifier = "test-multiple-2"
            message2.text = "Foobar 2"
            realm.add(message2)
        }

        XCTAssertNotNil(message1, "Message1 can't be nil")
        XCTAssertNotNil(message2, "Message2 can't be nil")

        var obj1 = ChatData(type: .message, timestamp: Date())
        obj1?.message = message1
        XCTAssertNotNil(obj1, "obj can't be nil")

        var obj2 = ChatData(type: .message, timestamp: Date())
        obj2?.message = message2
        XCTAssertNotNil(obj2, "obj can't be nil")

        if let obj1 = obj1, let obj2 = obj2 {
            let indexPaths = controller.insert([obj1, obj2])
            XCTAssertNotNil(indexPaths, "indexPaths can't be nil")
            XCTAssertEqual(indexPaths.count, 2, "indexPaths will have two results")
        }
    }

    func testInsertMultipleObjectsWithDifferentDates() {
        let controller = ChatDataController()

        var message1: Message!
        var message2: Message!
        Realm.executeOnMainThread { (realm) in
            message1 = Message()
            message1.identifier = "test-multiple-diff-1"
            message1.text = "Foobar 1"
            realm.add(message1)

            message2 = Message()
            message2.identifier = "test-multiple-diff-2"
            message2.text = "Foobar 2"
            realm.add(message2)
        }

        XCTAssertNotNil(message1, "Message1 can't be nil")
        XCTAssertNotNil(message2, "Message2 can't be nil")

        var obj1 = ChatData(type: .message, timestamp: Date().addingTimeInterval(-100000))
        obj1?.message = message1
        XCTAssertNotNil(obj1, "obj can't be nil")

        var obj2 = ChatData(type: .message, timestamp: Date())
        obj2?.message = message2
        XCTAssertNotNil(obj2, "obj can't be nil")

        if let obj1 = obj1, let obj2 = obj2 {
            let indexPaths = controller.insert([obj1, obj2])
            XCTAssertNotNil(indexPaths, "indexPaths can't be nil")
            XCTAssertEqual(indexPaths.count, 3, "indexPaths will have three results")
        }
    }

    func testUpdateObject() {
        let controller = ChatDataController()

        var message: Message!
        Realm.executeOnMainThread { (realm) in
            message = Message()
            message.identifier = "123"
            message.text = "Foobar"
            realm.add(message)
        }

        XCTAssertNotNil(message, "Message can't be nil")

        var obj = ChatData(type: .message, timestamp: Date())
        obj?.message = message
        XCTAssertNotNil(obj, "obj can't be nil")

        if let obj = obj {
            let indexPaths = controller.insert([obj])
            XCTAssertNotNil(indexPaths, "indexPaths can't be nil")
            XCTAssertEqual(indexPaths.count, 1, "indexPaths will have one result")
        }

        Realm.executeOnMainThread { (realm) in
            message.text = "Foobar, updated"
            realm.add(message, update: true)
        }

        let index = controller.update(message)
        XCTAssertEqual(index, 0, "indexPath is the message indexPath row")
        XCTAssertEqual(controller.data[index].message?.text, "Foobar, updated", "Message text was updated")
    }

}
