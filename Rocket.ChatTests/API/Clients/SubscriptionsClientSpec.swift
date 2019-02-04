//
//  SubscriptionsClient.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 5/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON
import RealmSwift

@testable import Rocket_Chat

// swiftlint:disable type_body_length
class SubscriptionsClientSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        Realm.execute({ realm in
            realm.deleteAll()
        })
    }

    func testFetchSubscriptionsList() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        Realm.execute({ realm in
            realm.add(auth, update: true)
        })

        api.nextResult = JSON([
            "result": [
                [
                    "t": "c",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "general",
                    "fname": nil,
                    "rid": "GENERAL",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "5ALsG3QhpJfdMpyc8"
                ],
                [
                    "t": "p",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "important",
                    "fname": nil,
                    "rid": "Ajalkjdaoiqw",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "LKSAJdklasd123"
                ]
            ],
            "success": true
        ])

        client.fetchSubscriptions(updatedSince: nil)
        XCTAssertEqual(Realm.current?.objects(Subscription.self).count, 2)
    }

    func testSubscriptionsUpdate() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        let subscription = Subscription.testInstance()
        subscription.identifier = "subscription-identifier"
        subscription.name = "internal"
        subscription.auth = auth

        Realm.execute({ realm in
            realm.add(auth, update: true)
            realm.add(subscription, update: true)
        })

        api.nextResult = JSON([
            "update": [
                [
                    "t": "c",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "general",
                    "fname": nil,
                    "rid": "GENERAL",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "subscription-identifier"
                ],
                [
                    "t": "p",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "important",
                    "fname": nil,
                    "rid": "Ajalkjdaoiqw",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "LKSAJdklasd123"
                ]
            ],
            "success": true
        ])

        client.fetchSubscriptions(updatedSince: nil)

        let subs = Realm.current?.objects(Subscription.self)
        XCTAssertEqual(subs?.count, 2)
        XCTAssertEqual(subs?[0].name, "general")
    }

    func testSubscriptionsRemove() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        let subscription = Subscription.testInstance()
        subscription.identifier = "subscription-identifier"
        subscription.auth = auth

        Realm.execute({ realm in
            realm.add(auth, update: true)
            realm.add(subscription, update: true)
        })

        api.nextResult = JSON([
            "remove": [
                [
                    "t": "c",
                    "ts": "2017-11-25T15:08:17.249Z",
                    "name": "general",
                    "fname": nil,
                    "rid": "GENERAL",
                    "_updatedAt": "2017-11-25T15:08:17.249Z",
                    "_id": "subscription-identifier"
                ]
            ],
            "success": true
        ])

        client.fetchSubscriptions(updatedSince: nil)

        let object = Realm.current?.objects(Subscription.self).first
        XCTAssertNotNil(object)
        XCTAssertNil(object?.auth)
    }

    func testSubscriptionsRoomMapping() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        let subscription = Subscription.testInstance()
        subscription.roomReadOnly = false
        subscription.rid = "subscription-rid"
        subscription.identifier = "subscription-identifier"
        subscription.auth = auth

        Realm.execute({ realm in
            realm.add(auth, update: true)
            realm.add(subscription, update: true)
        })

        api.nextResult = JSON([
            "update": [
                [
                    "_id": "subscription-rid",
                    "name": "123",
                    "fname": "123",
                    "t": "p",
                    "u": [
                        "_id": "hw5DThnhQmxDWnavu",
                        "username": "user2"
                    ],
                    "_updatedAt": "2018-01-24T21:02:04.318Z",
                    "customFields": [],
                    "ro": true
                ]
            ],
            "success": true
        ])

        client.fetchRooms(updatedSince: nil)

        let object = Realm.current?.objects(Subscription.self).first
        XCTAssertNotNil(object)
        XCTAssertTrue(object?.roomReadOnly ?? false)
    }

    func testFetchRoles() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let subscription = Subscription.testInstance("test-roles")
        let user = User.testInstance("test-user")
        let user2 = User.testInstance("test-user2")

        Realm.execute({ realm in
            realm.add(user, update: true)
            realm.add(user2, update: true)
            realm.add(subscription, update: true)
        })

        api.nextResult = JSON([
            "roles": [
                [
                    "u": [
                        "username": "test-user-username",
                        "_id": "test-user-identifier"
                    ],
                    "_id": "LG62dmF5XySq63GWk",
                    "rid": "test-roles-rid",
                    "roles": ["fixer", "moderator"]
                ],
                [
                    "u": [
                        "username": "test-user2-username",
                        "_id": "test-user2-identifier"
                    ],
                    "_id": "qa62dasdSq63Gak",
                    "rid": "test-roles-rid",
                    "roles": ["owner"]
                ]
            ],
            "success": true
        ])

        client.fetchRoles(subscription: subscription)

        guard
            let realm = Realm.current,
            let subscriptionObject = realm.objects(Subscription.self).first,
            let userObject = User.find(username: "test-user-username"),
            let user2Object = User.find(username: "test-user2-username")
        else {
            XCTFail("no results were found")
            return
        }

        XCTAssertEqual(userObject.rolesInSubscription(subscriptionObject).count, 2)
        XCTAssertEqual(user2Object.rolesInSubscription(subscriptionObject).count, 1)
    }

    // swiftlint:disable function_body_length
    func testLoadHistory() {
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let subscription = Subscription.testInstance("test-loadHistory")

        Realm.execute({ realm in
            realm.add(subscription, update: true)
        })

        let oldestString = "2016-12-06T17:57:38.635Z"
        let oldest = Date.dateFromString(oldestString)

        let ids = [
            "AkzpHAvZpdnuchw2a",
            "vkLMxcctR4MuTxreF",
            "bfRW658nEyEBg75rc",
            "pbuFiGadhRZTKouhB"
        ]

        api.nextResult = JSON([
            "messages": [
                [
                    "_id": ids[0],
                    "rid": "ByehQjC44FwMeiLbX",
                    "msg": "hi",
                    "ts": "2016-12-09T12:50:51.555Z",
                    "u": [
                        "_id": "y65tAmHs93aDChMWu",
                        "username": "testing"
                    ],
                    "_createdAt": "2016-12-09T12:50:51.562Z"
                ],
                [
                    "_id": ids[1],
                    "t": "uj",
                    "rid": "ByehQjC44FwMeiLbX",
                    "ts": "2016-12-08T15:41:37.730Z",
                    "msg": "testing2",
                    "u": [
                        "_id": "bRtgdhzM6PD9F8pSx",
                        "username": "testing2"
                    ],
                    "groupable": false,
                    "_createdAt": "2016-12-08T16:03:25.235Z"
                ],
                [
                    "_id": ids[2],
                    "t": "uj",
                    "rid": "ByehQjC44FwMeiLbX",
                    "ts": "2016-12-07T15:47:49.099Z",
                    "msg": "testing",
                    "u": [
                        "_id": "nSYqWzZ4GsKTX4dyK",
                        "username": "testing1"
                    ],
                    "groupable": false,
                    "_createdAt": "2016-12-07T15:47:49.099Z"
                ],
                [
                    "_id": ids[3],
                    "t": "uj",
                    "rid": "ByehQjC44FwMeiLbX",
                    "ts": "2016-12-06T17:57:38.635Z",
                    "msg": "testing",
                    "u": [
                        "_id": "y65tAmHs93aDChMWu",
                        "username": "testing"
                    ],
                    "groupable": false,
                    "_createdAt": oldestString
                ]
            ],
            "success": true
        ])

        let oldestDateIsCorrect = XCTestExpectation(description: "oldest date is correct")
        let messagesAreMapped = XCTestExpectation(description: "messages are mapped correctly")

        client.loadHistory(subscription: subscription, latest: nil, completion: { resultOldest in
            if oldest == resultOldest {
                oldestDateIsCorrect.fulfill()
            }

            let realm = Realm.current

            guard
                realm?.object(ofType: Message.self, forPrimaryKey: ids[0]) != nil,
                realm?.object(ofType: Message.self, forPrimaryKey: ids[1]) != nil,
                realm?.object(ofType: Message.self, forPrimaryKey: ids[2]) != nil,
                realm?.object(ofType: Message.self, forPrimaryKey: ids[3]) != nil
            else {
                return
            }

            messagesAreMapped.fulfill()
        })

        wait(for: [oldestDateIsCorrect, messagesAreMapped], timeout: 10)
    }
}
