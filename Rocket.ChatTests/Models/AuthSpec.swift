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

    //swiftlint:disable function_body_length
    func testCanDeleteMessage() {
        let realm = testRealm()

        let user1 = User.testInstance()
        user1.identifier = "uid1"

        let user2 = User.testInstance()
        user2.identifier = "uid2"

        let auth = Auth.testInstance()
        auth.userId = user1.identifier

        let message = Message.testInstance()
        message.identifier = "mid"
        message.user = user1

        // standard test

        try? realm.write {
            realm.add(auth)
            realm.add(user1)
            realm.add(user2)

            auth.settings?.messageAllowDeleting = true
            auth.settings?.messageAllowDeletingBlockDeleteInMinutes = 0
        }

        XCTAssert(auth.canDeleteMessage(message) == .allowed)

        // invalid message

        try? realm.write {
            message.createdAt = nil
        }

        XCTAssert(auth.canDeleteMessage(message) == .unknown)

        // non actionable message type

        try? realm.write {
            message.createdAt = Date()
            message.internalType = MessageType.userJoined.rawValue
        }

        XCTAssert(auth.canDeleteMessage(message) == .notActionable)

        // time elapsed

        try? realm.write {
            message.internalType = MessageType.text.rawValue
            message.createdAt = Date(timeInterval: -1000, since: Date())
            auth.settings?.messageAllowDeletingBlockDeleteInMinutes = 1
        }

        XCTAssert(auth.canDeleteMessage(message) == .timeElapsed)

        // different user

        try? realm.write {
            message.user = user2
        }

        XCTAssert(auth.canDeleteMessage(message) == .differentUser)

        // server blocked

        try? realm.write {
            auth.settings?.messageAllowDeleting = false
            message.user = user1
        }

        XCTAssert(auth.canDeleteMessage(message) == .serverBlocked)

        // force-delete-message permission

        let forcePermission = Permission()
        forcePermission.identifier = PermissionType.forceDeleteMessage.rawValue
        forcePermission.roles.append("admin")

        try? realm.write {
            message.user = user2
            realm.add(forcePermission)
            user1.roles.append("admin")
        }

        XCTAssert(auth.canDeleteMessage(message) == .allowed)

        // delete-message permission time elapsed

        let permission = Permission()
        permission.identifier = PermissionType.deleteMessage.rawValue
        permission.roles.append("admin")

        try? realm.write {
            forcePermission.roles.removeAll()
            realm.add(permission)
        }

        XCTAssert(auth.canDeleteMessage(message) == .timeElapsed)

        try? realm.write {
            auth.settings?.messageAllowDeletingBlockDeleteInMinutes = 0
        }

        XCTAssert(auth.canDeleteMessage(message) == .allowed)
    }

}
