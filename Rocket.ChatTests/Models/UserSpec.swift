//
//  UserSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

// MARK: Test Instance

extension User {
    static func testInstance(_ name: String = "user") -> User {
        let user = User()
        user.identifier = "\(name)-identifier"
        user.username = "\(name)-username"
        return user
    }
}

class UserSpec: XCTestCase, RealmTestCase {

    func testUserObject() {
        let object = User()
        object.identifier = "123"
        object.name = "Foo Bar Baz"
        object.username = "foobarbaz"

        let email = Email()
        email.email = "foo@bar.baz"
        object.emails.append(email)

        Realm.execute({ realm in
            realm.add(object, update: true)

            let results = realm.objects(User.self)
            let first = results.first
            XCTAssert(results.count == 1, "User object was created with success")
            XCTAssert(first?.identifier == "123", "User object was created with success")
        })
    }

    func testUserDisplayNameHonorFullnameSettings() {
        let settings = AuthSettings()
        settings.useUserRealName = false

        AuthSettingsManager.shared.internalSettings = settings

        let user = User()
        user.name = "Full Name"
        user.username = "username"

        XCTAssertNotEqual(user.displayName(), "Full Name", "User.displayName() won't return name property")
        XCTAssertEqual(user.displayName(), "username", "User.displayName() will return username property")
    }

    func testUserDisplayNameHonorNameSettings() {
        let settings = AuthSettings()
        settings.useUserRealName = true

        AuthSettingsManager.shared.internalSettings = settings

        let user = User()
        user.name = "Full Name"
        user.username = "username"

        XCTAssertEqual(user.displayName(), "Full Name", "User.displayName() will return name property")
        XCTAssertNotEqual(user.displayName(), "username", "User.displayName() won't return username property")
    }

    func testUserDisplayNameHonorNameSettingsWhenEmpty() {
        let settings = AuthSettings()
        settings.useUserRealName = true

        AuthSettingsManager.shared.internalSettings = settings

        let user = User()
        user.name = ""
        user.username = "username"

        XCTAssertEqual(user.displayName(), "username", "User.displayName() will return username property because name is empty")
    }

    func testUserDisplayNameHonorNameSettingsWhenNil() {
        let settings = AuthSettings()
        settings.useUserRealName = true

        AuthSettingsManager.shared.internalSettings = settings

        let user = User()
        user.username = "username"

        XCTAssertEqual(user.displayName(), "username", "User.displayName() will return username property because name is nil")
    }

    func testUserDisplayNameEmptySettings() {
        AuthSettingsManager.shared.internalSettings = nil

        let user = User()
        user.username = nil

        XCTAssertEqual(user.displayName(), "", "User.displayName() will return empty because settings is nil")
    }

    func testUserDisplayNameEmptyUsername() {
        let settings = AuthSettings()
        settings.useUserRealName = false

        AuthSettingsManager.shared.internalSettings = settings

        let user = User()
        user.username = nil

        XCTAssertEqual(user.displayName(), "", "User.displayName() will return empty because username is nil")
    }

    func testAvatarURLValid() {
        let auth = Auth.testInstance()
        let user = User.testInstance()
        let avatarURL = user.avatarURL(auth)
        XCTAssertNotNil(avatarURL, "url is valid")
        XCTAssertEqual(avatarURL?.absoluteString, "https://open.rocket.chat/avatar/user-username?format=jpeg", "avatar url is valid")
    }

    func testAvatarURLRandomUsername() {
        let auth = Auth.testInstance()
        let user = User.testInstance()
        user.username = String.random()

        let avatarURL = user.avatarURL(auth)
        XCTAssertNotNil(avatarURL, "url is valid")
        XCTAssertEqual(avatarURL?.absoluteString, "https://open.rocket.chat/avatar/\(user.username ?? "")?format=jpeg", "avatar url is valid")
    }

    func testAvatarURLInvalid() {
        let auth = Auth.testInstance()
        let user = User.testInstance()
        user.username = nil

        let avatarURL = user.avatarURL(auth)
        XCTAssertNil(avatarURL, "url is not valid")
    }

    func testDefaultStatus() {
        let user = User.testInstance()
        XCTAssertEqual(user.status, .offline, "default status is offline")
    }

    func testUserCanViewAdminPanelFalse() {
        let user = User.testInstance()
        XCTAssertFalse(user.canViewAdminPanel(), "user cannot view admin panel by default")
    }

    func testUserCanViewAdminPanelTrue() throws {
        let user = User.testInstance()
        user.roles.removeAll()
        user.roles.append("admin")

        let permissionType = PermissionType.viewRoomAdministration

        let permission = Rocket_Chat.Permission()
        permission.identifier = permissionType.rawValue
        permission.roles.append("admin")

        let realm = testRealm()
        try realm.write {
            realm.add(user)
            realm.add(permission)
        }

        XCTAssertTrue(user.canViewAdminPanel(realm: realm), "user cannot view admin panel by default")
    }

    func testMap() {
        let testJSON = JSON([
            "_id": "nSYqWzZ4GsKTX4dyK",
            "createdAt": "2016-12-07T15:47:46.861Z",
            "services": [
                "password": [
                    "bcrypt": "bcryptpass"
                ],
                "email": [
                    "verificationTokens": [
                        [
                            "token": "...",
                            "address": "example@example.com",
                            "when": "2016-12-07T15:47:46.930Z"
                        ]
                    ]
                ],
                "resume": [
                    "loginTokens": [
                        [
                            "when": "2016-12-07T15:47:47.334Z",
                            "hashedToken": "..."
                        ]
                    ]
                ]
            ],
            "emails": [
                [
                    "address": "example@example.com",
                    "verified": true
                ]
            ],
            "type": "user",
            "status": "offline",
            "active": true,
            "roles": [
                "user",
                "admin"
            ],
            "name": "Example User",
            "lastLogin": "2016-12-08T00:22:15.167Z",
            "statusConnection": "offline",
            "utcOffset": 0,
            "username": "example"
        ])

        let user = User()
        user.map(testJSON, realm: nil)

        XCTAssertTrue(user.roles.contains("user"), "has user role")
        XCTAssertTrue(user.roles.contains("admin"), "has admin role")
    }
}
