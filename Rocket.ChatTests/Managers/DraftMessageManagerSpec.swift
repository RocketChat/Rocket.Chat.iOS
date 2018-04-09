//
//  DraftMessageManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Filipe Alvarenga on 07/11/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class DraftMessageManagerSpec: XCTestCase {

    var servers: [[String: String]] = []
    let testServerURL = "wss://foo.com/websocket"
    let draftMessage = "Testing draft messages per channel"
    let subscription = Subscription.testInstance()

    override func setUp() {
        super.setUp()

        servers = [[
            ServerPersistKeys.databaseName: "foo.realm",
            ServerPersistKeys.serverURL: testServerURL,
            ServerPersistKeys.token: "1",
            ServerPersistKeys.userId: "1"
        ], [
            ServerPersistKeys.databaseName: "foo.realm"
        ]]
    }

    func testUpdateDraftMessageWithNoServers() {
        UserDefaults.standard.removeObject(forKey: ServerPersistKeys.servers)
        XCTAssertNoThrow(DraftMessageManager.update(draftMessage: "foo", for: subscription))
    }

    func testReturnDraftMessageWithNoServers() {
        UserDefaults.standard.removeObject(forKey: ServerPersistKeys.servers)
        XCTAssertEqual(DraftMessageManager.draftMessage(for: subscription), "", "it should return empty string")
    }

    func testReturnDraftMessageWithNotFoundServer() {
        UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 100)
        XCTAssertEqual(DraftMessageManager.draftMessage(for: subscription), "", "it should return empty string")
    }

    func testReturnDraftMessageWithEmptyServerURLKey() {
        UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 1)
        XCTAssertEqual(DraftMessageManager.draftMessage(for: subscription), "", "it should return empty string")
    }

    func testUpdateDraftMessage() {
        UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 0)
        DraftMessageManager.update(draftMessage: draftMessage, for: subscription)

        let selectedServerDraftMessages = UserDefaults.standard.dictionary(forKey: DraftMessageManager.selectedServerKey)
        let expectedSelectedServerDraftMessages: [String: Any] = [String(format: "\(subscription.rid)-cacheddraftmessage"): draftMessage]
        XCTAssertEqual(selectedServerDraftMessages as NSObject?, expectedSelectedServerDraftMessages as NSObject, "cached draft messages by server data is correct")
    }

    func testDraftMessageRetrieving() {
        UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 0)
        DraftMessageManager.update(draftMessage: draftMessage, for: subscription)

        XCTAssertEqual(DraftMessageManager.draftMessage(for: subscription), draftMessage, "draftMessage is correct")
    }

    func testClearEmptyServerDraftMessages() {
        UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 0)
        DraftMessageManager.update(draftMessage: draftMessage, for: subscription)

        UserDefaults.standard.set(nil, forKey: ServerPersistKeys.servers)
        DraftMessageManager.clearServerDraftMessages()

        XCTAssertNotNil(UserDefaults.standard.dictionary(forKey: testServerURL), "no server data was cleared when clearing draft messages for a empty server")
    }

    func testClearServerDraftMessages() {
        UserDefaults.standard.set(servers, forKey: ServerPersistKeys.servers)
        DatabaseManager.selectDatabase(at: 0)
        DraftMessageManager.update(draftMessage: draftMessage, for: subscription)

        DraftMessageManager.clearServerDraftMessages()
        XCTAssertNil(UserDefaults.standard.dictionary(forKey: DraftMessageManager.selectedServerKey), "successfully cleared selected server draft messages")
    }

}
