//
//  ServersListViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 30/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ServersListViewModelSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        DatabaseManager.clearAllServers()
    }

    override func tearDown() {
        super.tearDown()
        DatabaseManager.clearAllServers()
    }

    func testInitialState() {
        let instance = ServersListViewModel()
        XCTAssertEqual(instance.numberOfItems, 0)
        XCTAssertEqual(instance.serversList, [])
        XCTAssertEqual(instance.viewHeight, 0)
        XCTAssertEqual(instance.serverName(for: 0), "")
        XCTAssertTrue(instance.initialTableViewPosition < 0)
        XCTAssertFalse(instance.isSelectedServer(1))
        XCTAssertNil(instance.server(for: 0))
    }

    func testViewStateOneServer() {
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging1.rocket.chat")

        let instance = ServersListViewModel()
        XCTAssertEqual(instance.numberOfItems, 1)
        XCTAssertEqual(instance.serversList.count, 1)
        XCTAssertEqual(instance.viewHeight, ServerCell.cellHeight)
        XCTAssertEqual(instance.serverName(for: 0), "")
        XCTAssertTrue(instance.initialTableViewPosition < 0)
        XCTAssertTrue(instance.isSelectedServer(0))
        XCTAssertNotNil(instance.server(for: 0))
    }

    func testViewStateMultipleServers() {
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging1.rocket.chat")
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging2.rocket.chat")
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging3.rocket.chat")
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging4.rocket.chat")
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging5.rocket.chat")
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging6.rocket.chat")
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging7.rocket.chat")
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging8.rocket.chat")
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging9.rocket.chat")
        DatabaseManager.createNewDatabaseInstance(serverURL: "https://staging10.rocket.chat")
        DatabaseManager.selectDatabase(at: 5)

        let instance = ServersListViewModel()
        XCTAssertEqual(instance.numberOfItems, 10)
        XCTAssertEqual(instance.serversList.count, 10)
        XCTAssertEqual(instance.viewHeight, 6 * ServerCell.cellHeight)
        XCTAssertEqual(instance.serverName(for: 5), "")
        XCTAssertTrue(instance.initialTableViewPosition < 0)
        XCTAssertTrue(instance.isSelectedServer(5))
        XCTAssertNotNil(instance.server(for: 7))
    }

}
