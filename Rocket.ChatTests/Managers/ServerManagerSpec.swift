//
//  ServerManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ServerManagerSpec: XCTestCase {

    func testUpdateServerInformation() {
        let defaults = UserDefaults.group

        // Setup server for testing
        let servers = [[
            ServerPersistKeys.databaseName: "foo.realm",
            ServerPersistKeys.serverURL: "wss://foo.com/websocket",
            ServerPersistKeys.token: "1",
            ServerPersistKeys.userId: "1"
        ]]

        defaults.set(servers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 0)

        // Create a new server settings
        let settings = AuthSettings()
        settings.serverName = "serverName"
        settings.serverFaviconURL = "serverFaviconURL"

        // Update it
        ServerManager.updateServerInformation(from: settings)

        // Check information
        let server = DatabaseManager.servers?[DatabaseManager.selectedIndex]
        XCTAssertEqual(server?[ServerPersistKeys.serverName], "serverName", "serverName was updated")
        XCTAssertEqual(server?[ServerPersistKeys.serverIconURL], "serverFaviconURL", "serverFaviconURL was updated")
    }

    func testUpdateServerInformationInvalidSettings() {
        let defaults = UserDefaults.group

        // Setup server for testing
        let servers = [[
            ServerPersistKeys.databaseName: "foo.realm",
            ServerPersistKeys.serverURL: "wss://foo.com/websocket",
            ServerPersistKeys.token: "1",
            ServerPersistKeys.userId: "1"
        ]]

        defaults.set(servers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 0)

        // Create a new server settings
        let settings = AuthSettings()

        // Update it
        ServerManager.updateServerInformation(from: settings)

        // Check information
        let server = DatabaseManager.servers?[DatabaseManager.selectedIndex]
        XCTAssertNotEqual(server?[ServerPersistKeys.serverName], "serverName", "serverName was updated")
        XCTAssertNotEqual(server?[ServerPersistKeys.serverIconURL], "serverFaviconURL", "serverFaviconURL was updated")
    }

}
