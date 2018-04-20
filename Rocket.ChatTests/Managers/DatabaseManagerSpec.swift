//
//  DatabaseManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 06/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

private let testServers = [[
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

extension DatabaseManager {

    static func setupTestServers() {
        UserDefaults.group.set(testServers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 0)
    }

    static func clearAllServers() {
        UserDefaults.group.set([], forKey: ServerPersistKeys.servers)
    }

    static func removeServersKey() {
        UserDefaults.group.removeObject(forKey: ServerPersistKeys.servers)
    }
}

class DatabaseManagerSpec: XCTestCase {

    override func setUp() {
        DatabaseManager.setupTestServers()
    }

    func testSelectedIndex() {
        UserDefaults.group.set(0, forKey: ServerPersistKeys.selectedIndex)
        XCTAssertEqual(DatabaseManager.selectedIndex, 0, "selectedIndex is correct")
    }

    func testSelectedIndexEmpty() {
        UserDefaults.group.removeObject(forKey: ServerPersistKeys.selectedIndex)
        XCTAssertEqual(DatabaseManager.selectedIndex, 0, "selectedIndex returns 0 when value is nil")
    }

    func testServersListEmpty() {
        DatabaseManager.clearAllServers()
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
        UserDefaults.group.set(servers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 4)

        // Clear the invalids
        DatabaseManager.cleanInvalidDatabases()

        XCTAssertEqual(DatabaseManager.servers?.count, 1, "valid servers is only 1")
        XCTAssertEqual(DatabaseManager.selectedIndex, 0, "first item is selected")
    }

    func testCleanInvalidDatabasesNilList() {
        DatabaseManager.removeServersKey()
        XCTAssertNoThrow(DatabaseManager.cleanInvalidDatabases(), "clean works fine with nil list")
    }

    func testCleanInvalidDatabasesEmptyList() {
        DatabaseManager.clearAllServers()
        XCTAssertNoThrow(DatabaseManager.cleanInvalidDatabases(), "clean works fine with empty list")
    }

    func testChangeDatabaseInstanceWhenAllEmtpy() {
        DatabaseManager.clearAllServers()

        realmConfiguration = nil
        DatabaseManager.changeDatabaseInstance()

        XCTAssertNil(realmConfiguration, "realmConfiguration is still nil when there is no server")
    }

    func testCreateNewDatabaseInstanceWhenServersIsNil() {
        let serverURL = "wss://new.foo.bar"

        DatabaseManager.removeServersKey()
        DatabaseManager.createNewDatabaseInstance(serverURL: serverURL)

        let servers = DatabaseManager.servers
        let server = servers?.last

        XCTAssertEqual(server?[ServerPersistKeys.serverURL], serverURL, "server was added sucessffuly")
        XCTAssertNotNil(server?[ServerPersistKeys.databaseName], "new server database name isn't nil")
    }

    func testCreateNewDatabaseInstanceWhenAllEmtpy() {
        let serverURL = "wss://new.foo.bar"

        DatabaseManager.clearAllServers()
        DatabaseManager.createNewDatabaseInstance(serverURL: serverURL)

        let servers = DatabaseManager.servers
        let server = servers?.last

        XCTAssertEqual(server?[ServerPersistKeys.serverURL], serverURL, "server was added sucessffuly")
        XCTAssertNotNil(server?[ServerPersistKeys.databaseName], "new server database name isn't nil")
    }

    func testCreateNewDatabaseInstanceWhenServersExists() {
        DatabaseManager.setupTestServers()

        let serverURL = "wss://new.foo.bar"

        DatabaseManager.createNewDatabaseInstance(serverURL: serverURL)

        let servers = DatabaseManager.servers
        let server = servers?.last

        XCTAssertEqual(server?[ServerPersistKeys.serverURL], serverURL, "server was added sucessffuly")
        XCTAssertNotNil(server?[ServerPersistKeys.databaseName], "new server database name isn't nil")
    }

    func testServerIndexForUrl() {
        DatabaseManager.setupTestServers()

        guard
            let foo = URL(string: "https://foo.com"),
            let open = URL(string: "https://open.rocket.chat/"),
            let unexisting = URL(string: "https://unexisting.chat")
        else {
            return XCTFail("url(s) can not be nil")
        }

        XCTAssertEqual(DatabaseManager.serverIndexForUrl(foo), 0, "correct index for foo.com")
        XCTAssertEqual(DatabaseManager.serverIndexForUrl(open), 1, "correct index for open.rocket.chat")
        XCTAssertNil(DatabaseManager.serverIndexForUrl(unexisting), "index is nil for unexisting server")
    }

    func testCopyServerInformationNilServers() {
        DatabaseManager.removeServersKey()
        let newIndex = DatabaseManager.copyServerInformation(from: 0, with: "foo.com")
        XCTAssertEqual(newIndex, -1, "newIndex is a invalid index")
    }

    func testCopyServerInformationNoServers() {
        DatabaseManager.clearAllServers()
        let newIndex = DatabaseManager.copyServerInformation(from: 0, with: "foo.com")
        XCTAssertEqual(newIndex, -1, "newIndex is a invalid index")
    }

    func testCopyServerInformationValidServer() {
        DatabaseManager.setupTestServers()
        let newIndex = DatabaseManager.copyServerInformation(from: 0, with: "foo.com")
        XCTAssertEqual(newIndex, testServers.count - 1, "newIndex is latest server")
    }

    func testRemoveSelectedDatabase() {
        DatabaseManager.setupTestServers()
        DatabaseManager.removeSelectedDatabase()
        XCTAssertEqual(DatabaseManager.servers?.count ?? 0, testServers.count - 1, "servers lists minus one")
    }

}
