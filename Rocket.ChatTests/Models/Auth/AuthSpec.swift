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

// swiftlint:disable type_body_length file_length
class AuthSpec: XCTestCase {

    override func tearDown() {
        super.tearDown()
        Realm.clearDatabase()
    }

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

    func testAPIHostOnSubdirectory() {
        let object = Auth()
        object.serverURL = "wss://team.rocket.chat/subdirectory/websocket"

        XCTAssertEqual(object.apiHost?.absoluteString, "https://team.rocket.chat/subdirectory", "apiHost returns API Host correctly")
    }

    func testAPIHostInvalidServerURL() {
        let object = Auth()
        object.serverURL = ""

        XCTAssertNil(object.apiHost, "apiHost will be nil when serverURL is an invalid URL")
    }

    func testFirstChannelHasSeenDefaultTrue() {
        let object = Auth()
        XCTAssertTrue(object.internalFirstChannelOpened)
    }

    func testFirstChannelHasSeenChanges() {
        let object = Auth()
        object.internalFirstChannelOpened = false
        XCTAssertFalse(object.internalFirstChannelOpened)

        object.setFirstChannelOpened()
        XCTAssertTrue(object.internalFirstChannelOpened)
    }

    //swiftlint:disable function_body_length
    func testCanDeleteMessage() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        let user1 = User.testInstance()
        user1.identifier = "uid1"

        let user2 = User.testInstance()
        user2.identifier = "uid2"

        let auth = Auth.testInstance()
        auth.userId = user1.identifier

        let message = Message.testInstance()
        message.identifier = "mid"
        message.userIdentifier = user1.identifier

        // standard test

        realm.execute({ _ in
            realm.add(auth)
            realm.add(user1)
            realm.add(user2)

            auth.settings?.messageAllowDeleting = true
            auth.settings?.messageAllowDeletingBlockDeleteInMinutes = 0
        })

        XCTAssert(auth.canDeleteMessage(message) == .allowed)

        // invalid message

        realm.execute({ _ in
            message.createdAt = nil
        })

        XCTAssert(auth.canDeleteMessage(message) == .unknown)

        // non actionable message type

        realm.execute({ _ in
            message.createdAt = Date()
            message.internalType = MessageType.userJoined.rawValue
        })

        XCTAssert(auth.canDeleteMessage(message) == .notActionable)

        // time elapsed

        realm.execute({ _ in
            message.internalType = MessageType.text.rawValue
            message.createdAt = Date(timeInterval: -1000, since: Date())
            auth.settings?.messageAllowDeletingBlockDeleteInMinutes = 1
        })

        XCTAssert(auth.canDeleteMessage(message) == .timeElapsed)

        // different user

        realm.execute({ _ in
            message.userIdentifier = user2.identifier
        })

        XCTAssert(auth.canDeleteMessage(message) == .differentUser)

        // server blocked

        realm.execute({ _ in
            auth.settings?.messageAllowDeleting = false
            message.userIdentifier = user1.identifier
        })

        XCTAssert(auth.canDeleteMessage(message) == .serverBlocked)

        // force-delete-message permission

        let forcePermission = Rocket_Chat.Permission()
        forcePermission.identifier = PermissionType.forceDeleteMessage.rawValue
        forcePermission.roles.append("admin")

        realm.execute({ _ in
            message.userIdentifier = user2.identifier
            realm.add(forcePermission)
            user1.roles.append("admin")
        })

        XCTAssert(auth.canDeleteMessage(message) == .allowed)

        // delete-message permission time elapsed

        let permission = Rocket_Chat.Permission()
        permission.identifier = PermissionType.deleteMessage.rawValue
        permission.roles.append("admin")

        realm.execute({ _ in
            forcePermission.roles.removeAll()
            realm.add(permission)
        })

        XCTAssert(auth.canDeleteMessage(message) == .timeElapsed)

        realm.execute({ _ in
            auth.settings?.messageAllowDeletingBlockDeleteInMinutes = 0
        })

        XCTAssert(auth.canDeleteMessage(message) == .allowed)
    }

    // swiftlint:disable function_body_length
    func testCanEditMessage() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        let user1 = User.testInstance()
        user1.identifier = "uid1"

        let user2 = User.testInstance()
        user2.identifier = "uid2"

        let auth = Auth.testInstance()
        auth.userId = user1.identifier

        let message = Message.testInstance()
        message.identifier = "mid"
        message.userIdentifier = user1.identifier

        // standard test

        realm.execute({ _ in
            realm.add(auth)
            realm.add(user1)
            realm.add(user2)

            auth.settings?.messageAllowEditing = true
            auth.settings?.messageAllowEditingBlockEditInMinutes = 0
        })

        XCTAssert(auth.canEditMessage(message) == .allowed)

        // invalid message

        realm.execute({ _ in
            message.createdAt = nil
        })

        XCTAssert(auth.canEditMessage(message) == .unknown)

        // non actionable message type

        realm.execute({ _ in
            message.createdAt = Date()
            message.internalType = MessageType.userJoined.rawValue
        })

        XCTAssert(auth.canEditMessage(message) == .notActionable)

        // time elapsed

        realm.execute({ _ in
            message.internalType = MessageType.text.rawValue
            message.createdAt = Date(timeInterval: -1000, since: Date())
            auth.settings?.messageAllowEditingBlockEditInMinutes = 1
        })

        XCTAssert(auth.canEditMessage(message) == .timeElapsed)

        // different user

        realm.execute({ _ in
            message.userIdentifier = user2.identifier
        })

        XCTAssert(auth.canEditMessage(message) == .differentUser)

        // server blocked

        realm.execute({ _ in
            auth.settings?.messageAllowEditing = false
            message.userIdentifier = user1.identifier
        })

        XCTAssert(auth.canEditMessage(message) == .serverBlocked)

        // edit-message

        let permission = Rocket_Chat.Permission()
        permission.identifier = PermissionType.editMessage.rawValue
        permission.roles.append("admin")

        realm.execute({ _ in
            user1.roles.append("admin")
            message.userIdentifier = user2.identifier
            realm.add(permission)
        })

        XCTAssert(auth.canEditMessage(message) == .allowed)
    }

    func testCanBlockMessage() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        let user1 = User.testInstance()
        user1.identifier = "uid1"

        let user2 = User.testInstance()
        user2.identifier = "uid2"

        let auth = Auth.testInstance()
        auth.userId = user1.identifier

        let message = Message.testInstance()
        message.identifier = "mid"
        message.userIdentifier = user2.identifier

        // block-message

        realm.execute({ _ in
            realm.add(auth)
            realm.add(user1)
            realm.add(user2)
        })

        XCTAssert(auth.canBlockMessage(message) == .allowed)

        // my own message

        realm.execute({ _ in
            message.userIdentifier = user1.identifier
        })

        XCTAssert(auth.canBlockMessage(message) == .myOwn)

        // non actionable message type

        realm.execute({ _ in
            message.createdAt = Date()
            message.internalType = MessageType.userJoined.rawValue
        })

        XCTAssert(auth.canBlockMessage(message) == .notActionable)

    }

    func testCanPinMessage() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        let user1 = User.testInstance()
        user1.identifier = "uid1"
        user1.roles.append("admin")

        let user2 = User.testInstance()
        user2.identifier = "uid2"
        user2.roles.append("admin")

        let auth = Auth.testInstance()
        auth.userId = user1.identifier

        let message = Message.testInstance()
        message.identifier = "mid"
        message.userIdentifier = user1.identifier

        let permission = Rocket_Chat.Permission()
        permission.identifier = PermissionType.pinMessage.rawValue
        permission.roles.append("admin")

        realm.execute({ _ in
            realm.add(permission)
            realm.add(auth)
            realm.add(user1)
            realm.add(user2)

            auth.settings?.messageAllowPinning = true
        })

        // User & Server have permission
        XCTAssertEqual(auth.canPinMessage(message), .allowed)

        // Message is not actionable
        realm.execute({ _ in
            message.createdAt = Date()
            message.internalType = MessageType.userJoined.rawValue
        })

        XCTAssertEqual(auth.canPinMessage(message), .notActionable)

        // Server permission doesn't allow to pin
        realm.execute({ _ in
            auth.settings?.messageAllowPinning = false
            message.userIdentifier = user1.identifier
            message.internalType = MessageType.text.rawValue
        })

        XCTAssertEqual(auth.canPinMessage(message), .notAllowed)

        // User without the role required but server allows to
        realm.execute({ _ in
            user1.roles.removeAll()
            auth.settings?.messageAllowPinning = true
        })

        XCTAssertEqual(auth.canPinMessage(message), .notAllowed)
    }
}
