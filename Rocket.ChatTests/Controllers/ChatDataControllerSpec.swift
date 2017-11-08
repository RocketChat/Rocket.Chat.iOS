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
    func testInitilization() {
        let controller = ChatDataController()
        XCTAssertEqual(controller.data.count, 0, "Controller has no data on initialization")
    }

    func testInsertObject() {
        let controller = ChatDataController()

        let message = Message()
        message.identifier = "123"
        message.text = "Foobar"

        XCTAssertNotNil(message, "Message can't be nil")

        var obj = ChatData(type: .message, timestamp: Date())
        obj.message = message
        XCTAssertNotNil(obj, "obj can't be nil")

        let (indexPaths, _) = controller.insert([obj])
        XCTAssertNotNil(indexPaths, "indexPaths can't be nil")
        XCTAssertEqual(indexPaths.count, 2, "indexPaths will have two results")
    }

    func testInsertMultipleObjects() {
        let controller = ChatDataController()

        let message1 = Message()
        message1.identifier = "test-multiple-1"
        message1.text = "Foobar 1"

        let message2 = Message()
        message2.identifier = "test-multiple-2"
        message2.text = "Foobar 2"

        XCTAssertNotNil(message1, "Message1 can't be nil")
        XCTAssertNotNil(message2, "Message2 can't be nil")

        var obj1 = ChatData(type: .message, timestamp: Date())
        obj1.message = message1

        var obj2 = ChatData(type: .message, timestamp: Date())
        obj2.message = message2

        let (indexPaths, _) = controller.insert([obj1, obj2])
        XCTAssertNotNil(indexPaths, "indexPaths can't be nil")
        XCTAssertEqual(indexPaths.count, 3, "indexPaths will have three results")
    }

    func testInsertMultipleObjectsWithDifferentDates() {
        let controller = ChatDataController()

        let message1 = Message()
        message1.identifier = "test-multiple-diff-1"
        message1.text = "Foobar 1"

        let message2 = Message()
        message2.identifier = "test-multiple-diff-2"
        message2.text = "Foobar 2"

        XCTAssertNotNil(message1, "Message1 can't be nil")
        XCTAssertNotNil(message2, "Message2 can't be nil")

        var obj1 = ChatData(type: .message, timestamp: Date().addingTimeInterval(-100000))
        obj1.message = message1

        var obj2 = ChatData(type: .message, timestamp: Date())
        obj2.message = message2

        let (indexPaths, _) = controller.insert([obj1, obj2])
        XCTAssertNotNil(indexPaths, "indexPaths can't be nil")
        XCTAssertEqual(indexPaths.count, 4, "indexPaths will have four results")
    }

    func testUpdateObject() {
        let controller = ChatDataController()

        let message = Message()
        message.identifier = "update-1"
        message.text = "Foobar"

        var obj = ChatData(type: .message, timestamp: Date())
        obj.message = message

        let (indexPaths, _) = controller.insert([obj])
        XCTAssertNotNil(indexPaths, "indexPaths can't be nil")
        XCTAssertEqual(indexPaths.count, 2, "indexPaths will have three results")

        message.text = "Foobar, updated"

        let index = controller.update(message)
        XCTAssertEqual(index, 1, "indexPath is the message indexPath row")
        XCTAssertEqual(controller.data[index].message?.text, "Foobar, updated", "Message text was updated")
    }

    func testLoaderObject() {
        let controller = ChatDataController()

        let message1 = Message()
        message1.identifier = "test-loader-1"
        message1.text = "Foobar 1"

        var obj1 = ChatData(type: .message, timestamp: Date())
        obj1.message = message1

        let (indexPaths, _) = controller.insert([obj1])
        XCTAssertNotNil(indexPaths, "indexPaths can't be nil")
        XCTAssertEqual(indexPaths.count, 2, "indexPaths will have two results")
        XCTAssertEqual(controller.data.filter({ $0.type == .loader }).count, 1, "data will have 1 loader")
        XCTAssertEqual(controller.data.filter({ $0.type == .header }).count, 0, "data will have 0 header")
    }

    func testLoadedAllMessagesHeaderObject() {
        let controller = ChatDataController()
        controller.loadedAllMessages = true

        let message1 = Message()
        message1.identifier = "test-header-1"
        message1.text = "Foobar 1"

        var obj1 = ChatData(type: .message, timestamp: Date())
        obj1.message = message1

        let (indexPaths, _) = controller.insert([obj1])
        XCTAssertNotNil(indexPaths, "indexPaths can't be nil")
        XCTAssertEqual(indexPaths.count, 2, "indexPaths will have two results")
        XCTAssertEqual(controller.data.filter({ $0.type == .loader }).count, 0, "data will have 0 loader")
        XCTAssertEqual(controller.data.filter({ $0.type == .header }).count, 1, "data will have 1 header")
    }

    func testHasSequentialMessage() {
        let controller = ChatDataController()

        let message1 = Message()
        message1.identifier = "message1-sequential"
        message1.groupable = true
        message1.createdAt = Date()

        let message2 = Message()
        message2.identifier = "message2-sequential"
        message2.groupable = true
        message2.createdAt = Date() + (Message.maximumTimeForSequence - 1.0)

        var data1 = ChatData(type: .message, timestamp: Date())
        data1.message = message1
        var data2 = ChatData(type: .message, timestamp: Date())
        data2.message = message2

        controller.insert([data1, data2])

        let indexPaths = controller.data.filter {
            $0.message?.identifier == "message2-sequential"
        }
        guard let indexPath = indexPaths.last?.indexPath else {
            XCTFail("message2 not found in data")
            return
        }

        XCTAssert(controller.hasSequentialMessageAt(indexPath), "message2 is sequential")

        message2.groupable = false

        XCTAssertFalse(controller.hasSequentialMessageAt(indexPath), "message2 is not sequential")

        message2.groupable = true
        message2.createdAt?.addTimeInterval(2.0)

        XCTAssertFalse(controller.hasSequentialMessageAt(indexPath), "message2 is not sequential")
    }
}
