//
//  SubscriptionsClient.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 5/9/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SubscriptionsClientSpec: XCTestCase, RealmTestCase {
    func testFetchSubscriptionsList() {
        let realm = testRealm()
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        try? realm.write {
            realm.add(auth, update: true)
        }

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

        let expectation = XCTestExpectation(description: "number of subscriptions is correct")

        client.fetchSubscriptions(updatedSince: nil, realm: realm)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if realm.objects(Subscription.self).count == 2 {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testSubscriptionsUpdate() {
        let realm = testRealm()
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        let subscription = Subscription.testInstance()
        subscription.identifier = "subscription-identifier"
        subscription.name = "internal"
        subscription.auth = auth

        try? realm.write {
            realm.add(auth, update: true)
            realm.add(subscription, update: true)
        }

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

        let expectation = XCTestExpectation(description: "number of subscriptions is correct")

        client.fetchSubscriptions(updatedSince: nil, realm: realm)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let subs = realm.objects(Subscription.self)
            if subs.count == 2, subs[0].name == "general" {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testSubscriptionsRemove() {
        let realm = testRealm()
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        let subscription = Subscription.testInstance()
        subscription.identifier = "subscription-identifier"
        subscription.auth = auth

        try? realm.write {
            realm.add(auth, update: true)
            realm.add(subscription, update: true)
        }

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

        let expectation = XCTestExpectation(description: "number of subscriptions is correct")

        client.fetchSubscriptions(updatedSince: nil, realm: realm)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let subscription = realm.objects(Subscription.self).first, subscription.auth == nil {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testSubscriptionsRoomMapping() {
        let realm = testRealm()
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let auth = Auth.testInstance()

        let subscription = Subscription.testInstance()
        subscription.roomReadOnly = false
        subscription.rid = "subscription-rid"
        subscription.identifier = "subscription-identifier"
        subscription.auth = auth

        try? realm.write {
            realm.add(auth, update: true)
            realm.add(subscription, update: true)
        }

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

        let expectation = XCTestExpectation(description: "subscription read only field was updated correctly")

        client.fetchRooms(updatedSince: nil, realm: realm)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if let subscription = realm.objects(Subscription.self).first, subscription.roomReadOnly == true {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }

    func testFetchRoles() {
        let realm = testRealm()
        let api = MockAPI()
        let client = SubscriptionsClient(api: api)
        let subscription = Subscription.testInstance("test-roles")
        let user = User.testInstance("test-user")
        let user2 = User.testInstance("test-user2")

        try? realm.write {
            realm.add(user, update: true)
            realm.add(user2, update: true)
            realm.add(subscription, update: true)
        }

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

        client.fetchRoles(subscription: subscription, realm: realm)

        let expectation = XCTestExpectation(description: "subscription has correct roles for user")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4, execute: {
            guard
                let subscription = realm.objects(Subscription.self).first,
                let user = User.find(username: "test-user-username", realm: realm),
                let user2 = User.find(username: "test-user2-username", realm: realm)
            else {
                return
            }

            if user.rolesInSubscription(subscription).count == 2, user2.rolesInSubscription(subscription).count == 1 {
                expectation.fulfill()
            }
        })
        wait(for: [expectation], timeout: 3)
    }
}
