//
//  MessagesViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Streit on 26/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import XCTest

@testable import Rocket_Chat

final class MessagesViewModelSpec: XCTestCase {

    func testInitialState() {
        let model = MessagesViewModel()
        XCTAssertEqual(model.data.count, 0)
        XCTAssertFalse(model.requestingData)
        XCTAssertTrue(model.hasMoreData)
    }

    func testSectionCreationBasic() {
        let model = MessagesViewModel()

        guard
            let testCaseMessage = Message.testInstance().validated()?.unmanaged,
            let section = model.section(for: testCaseMessage)
        else {
            return XCTFail("section must be created")
        }

        if let object = section.base.object.base as? MessageSectionModel {
            XCTAssertEqual(object.message.identifier, testCaseMessage.identifier)
            XCTAssertFalse(object.isSequential)
            XCTAssertFalse(object.containsDateSeparator)
            XCTAssertFalse(object.containsUnreadMessageIndicator)
        } else {
            XCTFail("object must be a MessageSectionModel instance")
        }
    }

    func testNumberOfSections() {
        let model = MessagesViewModel()

        if let testCaseMessage = Message.testInstance().validated()?.unmanaged, let section = model.section(for: testCaseMessage) {
            model.data = [section]
        }

        XCTAssertEqual(model.numberOfSections, 1)
    }

    func testOldestDatePresent() {
        let model = MessagesViewModel()

        let testDate = Date().addingTimeInterval(-10000)
        guard
            let messageFirst = Message.testInstance().validated()?.unmanaged,
            var messageSecond = Message.testInstance().validated()?.unmanaged
        else {
            return XCTFail("messages must be created")
        }

        messageSecond.createdAt = testDate

        if let section1 = model.section(for: messageFirst), let section2 = model.section(for: messageSecond) {
            model.data = [section1, section2]
        }

        XCTAssertEqual(model.numberOfSections, 2)
        XCTAssertEqual(model.oldestMessageDateBeingPresented, testDate)
    }

    func testSequentialMessages() {
        let model = MessagesViewModel()

        guard
            let messageFirst = Message.testInstance().validated()?.unmanaged,
            var messageSecond = Message.testInstance().validated()?.unmanaged
        else {
            return XCTFail("messages must be created")
        }

        messageSecond.createdAt = Date().addingTimeInterval(-1)

        if let section1 = model.section(for: messageFirst), let section2 = model.section(for: messageSecond) {
            model.data = [section1, section2]
            model.cacheDataSorted()
            model.normalizeDataSorted()
        }

        XCTAssertEqual(model.numberOfSections, 2)

        guard
            let object1 = model.dataSorted[0].object.base as? MessageSectionModel,
            let object2 = model.dataSorted[1].object.base as? MessageSectionModel
        else {
            return XCTFail("objects must be valid sections")
        }

        XCTAssertTrue(object1.isSequential)
        XCTAssertFalse(object2.isSequential)
    }

    func testLoaderPresenceTrue() {
        let model = MessagesViewModel()

        guard
            let messageFirst = Message.testInstance().validated()?.unmanaged,
            let messageSecond = Message.testInstance().validated()?.unmanaged
        else {
            return XCTFail("messages must be created")
        }

        if let section1 = model.section(for: messageFirst), let section2 = model.section(for: messageSecond) {
            model.data = [section1, section2]
            model.cacheDataSorted()
            model.normalizeDataSorted()
        }

        XCTAssertEqual(model.numberOfSections, 2)

        guard
            let object1 = model.dataSorted[0].object.base as? MessageSectionModel,
            let object2 = model.dataSorted[1].object.base as? MessageSectionModel
        else {
            return XCTFail("objects must be valid sections")
        }

        XCTAssertFalse(object1.containsLoader)
        XCTAssertFalse(object1.containsHeader)
        XCTAssertTrue(object2.containsLoader)
        XCTAssertFalse(object2.containsHeader)
    }

    func testLoaderPresenceFalse() {
        let model = MessagesViewModel()

        guard
            let messageFirst = Message.testInstance().validated()?.unmanaged,
            let messageSecond = Message.testInstance().validated()?.unmanaged
        else {
            return XCTFail("messages must be created")
        }

        if let section1 = model.section(for: messageFirst), let section2 = model.section(for: messageSecond) {
            model.hasMoreData = false
            model.requestingData = false
            model.data = [section1, section2]
            model.cacheDataSorted()
            model.normalizeDataSorted()
        }

        XCTAssertEqual(model.numberOfSections, 2)

        guard
            let object1 = model.dataSorted[0].object.base as? MessageSectionModel,
            let object2 = model.dataSorted[1].object.base as? MessageSectionModel
        else {
            return XCTFail("objects must be valid sections")
        }

        XCTAssertFalse(object1.containsLoader)
        XCTAssertFalse(object1.containsHeader)
        XCTAssertFalse(object2.containsLoader)
        XCTAssertTrue(object2.containsHeader)
    }

}
