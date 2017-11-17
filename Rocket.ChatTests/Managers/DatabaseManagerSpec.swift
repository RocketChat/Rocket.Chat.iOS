//
//  DatabaseManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 06/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

extension DatabaseManager {
    static func setupTestServers() {
        let servers = [[
            ServerPersistKeys.databaseName: "foo.realm",
            ServerPersistKeys.serverURL: "wss://foo.com/websocket",
            ServerPersistKeys.token: "1",
            ServerPersistKeys.userId: "1"
        ], [
            ServerPersistKeys.databaseName: "open.realm",
            ServerPersistKeys.serverURL: "wss://open.rocket.chat/websocket",
            ServerPersistKeys.token: "1",
            ServerPersistKeys.userId: "1"
        ]]

        UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)
    }
}

class DatabaseManagerSpec: XCTestCase {

    func testSelectedIndex() {
        UserDefaults.standard.set(0, forKey: ServerPersistKeys.selectedIndex)
        XCTAssertEqual(DatabaseManager.selectedIndex, 0, "selectedIndex is correct")
    }

    func testSelectedIndexEmpty() {
        UserDefaults.standard.removeObject(forKey: ServerPersistKeys.selectedIndex)
        XCTAssertEqual(DatabaseManager.selectedIndex, 0, "selectedIndex returns 0 when value is nil")
    }

    func testServersListEmpty() {
        let servers: [[String: String]] = []
        UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)
        XCTAssertEqual(DatabaseManager.servers?.count, 0, "no servers into empty list")
    }

    func testServersList() {
        DatabaseManager.setupTestServers()
        XCTAssertEqual(DatabaseManager.servers?.count, 2, "2 servers into the list")
    }

    func testSelectDatabase() {
        DatabaseManager.selectDatabase(at: 10)
        XCTAssertEqual(DatabaseManager.selectedIndex, 10, "selectedDatabase index is 10")
    }

    func testClearInvalidDatabases() {
        let servers = [[
            // Valid
            ServerPersistKeys.databaseName: "foo.realm",
            ServerPersistKeys.serverURL: "wss://foo.com/websocket",
            ServerPersistKeys.token: "1",
            ServerPersistKeys.userId: "1"
        ], [
            // Invalid
            ServerPersistKeys.databaseName: "foo.realm",
            ServerPersistKeys.serverURL: "wss://foo.com/websocket"
        ], [
            // Invalid
            ServerPersistKeys.databaseName: "foo.realm"
        ], [
            // Invalid
            ServerPersistKeys.serverURL: "wss://foo.com/websocket"
        ], [
            // Invalid
            ServerPersistKeys.token: "1"
        ]]

        // Setup servers & a different selected index
        UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 4)

        // Clear the invalids
        DatabaseManager.cleanInvalidDatabases()

        XCTAssertEqual(DatabaseManager.servers?.count, 1, "valid servers is only 1")
        XCTAssertEqual(DatabaseManager.selectedIndex, 0, "first item is selected")
    }

    func testCreateNewDatabaseInstance() {
        let serverURL = "wss://new.foo.bar"

        DatabaseManager.createNewDatabaseInstance(serverURL: serverURL)

        let servers = DatabaseManager.servers
        let server = servers?.last

        XCTAssertEqual(server?[ServerPersistKeys.serverURL], serverURL, "server was added sucessffuly")
        XCTAssertNotNil(server?[ServerPersistKeys.databaseName], "new server database name isn't nil")
    }

    func testServerIndexForUrl() {
        DatabaseManager.setupTestServers()
        XCTAssertEqual(DatabaseManager.serverIndexForUrl("wss://foo.com/websocket"), 0, "correct index for foo.com")
        XCTAssertEqual(DatabaseManager.serverIndexForUrl("wss://open.rocket.chat/websocket"), 1, "correct index for open.rocket.chat")
        XCTAssertNil(DatabaseManager.serverIndexForUrl("wss://unexisting.chat/websocket"), "index is nil for unexisting server")
    }
}
