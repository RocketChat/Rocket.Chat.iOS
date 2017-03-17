//
//  SubscriptionSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

class SubscriptionSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        Realm.execute { realm in
            for obj in realm.objects(Auth.self) {
                realm.delete(obj)
            }

            for obj in realm.objects(Subscription.self) {
                realm.delete(obj)
            }
        }
    }

    func testSubscriptionObject() {
        let auth = Auth()
        auth.serverURL = "http://foo.bar.baz"

        let object = Subscription()
        object.auth = auth
        object.identifier = "123"
        object.rid = "123"
        object.name = "Foo Bar Baz"
        object.unread = 10
        object.open = false
        object.alert = true
        object.favorite = true
        object.createdAt = Date()
        object.lastSeen = Date()

        Realm.execute { realm in
            realm.add(object)

            let results = realm.objects(Subscription.self)
            let first = results.first
            XCTAssert(results.count == 1, "Subscription object was created with success")
            XCTAssert(first?.identifier == "123", "Subscription object was created with success")
            XCTAssert(auth.subscriptions.first?.identifier == first?.identifier, "Auth relationship with Subscription is OK")
        }
    }

    func testSubscriptionObjectFromJSON() {
        let object = JSON([
            "_id": "123",
            "rid": "123",
            "name": "Foo Bar Baz",
            "unread": 0,
            "open": false,
            "alert": true,
            "f": false,
            "ts": ["$date": 1234567891011],
            "ls": ["$date": 1234567891011]
        ])

        let auth = Auth()
        auth.serverURL = "http://foo.bar.baz"

        let subscription = Subscription(value: object)
        subscription.auth = auth

        Realm.execute { realm in
            realm.add(subscription)

            let results = realm.objects(Subscription.self)
            let first = results.first
            XCTAssert(results.count == 1, "Subscription object was created with success")
            XCTAssert(first?.identifier == "123", "Subscription object was created with success")
            XCTAssert(auth.subscriptions.first?.identifier == first?.identifier, "Auth relationship with Subscription is OK")
        }
    }
}
