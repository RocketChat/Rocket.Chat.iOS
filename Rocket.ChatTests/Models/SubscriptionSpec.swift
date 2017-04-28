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

        var uniqueConfiguration = Realm.Configuration.defaultConfiguration
        uniqueConfiguration.inMemoryIdentifier = NSUUID().uuidString
        Realm.Configuration.defaultConfiguration = uniqueConfiguration

        Realm.executeOnMainThread({ (realm) in
            realm.deleteAll()
        })
    }

    func testSubscriptionObject() {
        Realm.executeOnMainThread({ realm in
            let auth = Auth()
            auth.serverURL = "http://foo.bar.baz"

            let object = Subscription()
            object.auth = auth
            object.identifier = "subs-from-data"
            object.rid = "subs-from-data-rid"
            object.name = "Foo Bar Baz"
            object.unread = 10
            object.open = false
            object.alert = true
            object.favorite = true
            object.createdAt = Date()
            object.lastSeen = Date()

            realm.add(object, update: true)

            let results = realm.objects(Subscription.self)
            let first = results.first
            XCTAssert(results.count == 1, "Subscription object was created with success")
            XCTAssert(first?.identifier == "subs-from-data", "Subscription object was created with success")
            XCTAssert(auth.subscriptions.first?.identifier == first?.identifier, "Auth relationship with Subscription is OK")
        })
    }

    func testSubscriptionObjectFromJSON() {
        let object = JSON([
            "_id": "subs-from-json-1",
            "rid": "subs-from-json-1-rid",
            "name": "Foo Bar Baz",
            "unread": 0,
            "open": false,
            "alert": true,
            "f": false,
            "ts": ["$date": 1234567891011],
            "ls": ["$date": 1234567891011]
        ])

        Realm.executeOnMainThread({ realm in
            let auth = Auth()
            auth.serverURL = "http://foo.bar.baz"

            let subscription = Subscription()
            subscription.map(object, realm: realm)
            subscription.auth = auth

            realm.add(subscription, update: true)

            let results = realm.objects(Subscription.self)
            let first = results.first
            XCTAssert(results.count == 1, "Subscription object was created with success")
            XCTAssert(first?.identifier == "subs-from-json-1", "Subscription object was created with success")
            XCTAssert(auth.subscriptions.first?.identifier == first?.identifier, "Auth relationship with Subscription is OK")
        })
    }
}
