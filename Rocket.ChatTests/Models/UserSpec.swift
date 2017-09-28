//
//  UserSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class UserSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        var uniqueConfiguration = Realm.Configuration.defaultConfiguration
        uniqueConfiguration.inMemoryIdentifier = NSUUID().uuidString
        Realm.Configuration.defaultConfiguration = uniqueConfiguration

        Realm.executeOnMainThread({ (realm) in
            realm.deleteAll()
        })
    }

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
}
