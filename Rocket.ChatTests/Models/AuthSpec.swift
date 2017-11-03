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

class AuthSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        var uniqueConfiguration = Realm.Configuration.defaultConfiguration
        uniqueConfiguration.inMemoryIdentifier = NSUUID().uuidString
        Realm.Configuration.defaultConfiguration = uniqueConfiguration

        Realm.executeOnMainThread({ realm in
            realm.deleteAll()
        })
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
}
