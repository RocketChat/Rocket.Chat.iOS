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

        Realm.executeOnMainThread({ realm in
            for obj in realm.objects(User.self) {
                realm.delete(obj)
            }

            for obj in realm.objects(Email.self) {
                realm.delete(obj)
            }
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
}
