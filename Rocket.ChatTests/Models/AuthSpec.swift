//
//  AuthSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

// MARK: Test Instance

extension Auth {
    static func testInstance() -> Auth {
        let auth = Auth()
        auth.settings = AuthSettings.testInstance()
        auth.serverURL = "wss://open.rocket.chat/websocket"
        auth.serverVersion = "1.2.3"
        auth.userId = "auth-userid"
        auth.token = "auth-token"
        return auth
    }
}

class AuthSpec: XCTestCase, RealmTestCase {

    // MARK: Setup

    override func setUp() {
        super.setUp()

        var uniqueConfiguration = Realm.Configuration.defaultConfiguration
        uniqueConfiguration.inMemoryIdentifier = NSUUID().uuidString
        Realm.Configuration.defaultConfiguration = uniqueConfiguration

        Realm.executeOnMainThread({ realm in
            realm.deleteAll()
        })
    }

    // MARK: Tests

    func testAuthObject() {
        let serverURL = "http://foobar.com"
        let object = Auth()
        object.serverURL = serverURL
        object.token = "123"
        object.tokenExpires = Date()
        object.lastAccess = Date()
        object.userId = "123"

        Realm.execute({ realm in
            realm.add(object)

            let results = realm.objects(Auth.self)
            let first = results.first
            XCTAssert(results.count == 1, "Auth object was created with success")
            XCTAssert(first?.serverURL == serverURL, "Auth object was created with success")
        })
    }

    func testAPIHost() {
        let object = Auth()
        object.serverURL = "wss://team.rocket.chat/websocket"

        XCTAssertEqual(object.apiHost?.absoluteString, "https://team.rocket.chat", "apiHost returns API Host correctly")
    }

    func testAPIHostInvalidServerURL() {
        let object = Auth()
        object.serverURL = ""

        XCTAssertNil(object.apiHost, "apiHost will be nil when serverURL is an invalid URL")
    }

    func testCanDeleteMessage() {
        let realm = testRealm()

        let auth = Auth.testInstance()
        auth.userId = "uid"

        let user = User.testInstance()
        user.identifier = "uid"

        let message = Message.testInstance()
        message.identifier = "mid"
        message.user = user

        try? realm.write {
            realm.add(auth)
            realm.add(user)

            auth.settings?.messageAllowDeleting = true
            auth.settings?.messageAllowDeletingBlockDeleteInMinutes = 0
        }

        XCTAssert(auth.canDeleteMessage(message) == .allowed)
    }

}
