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

        client.fetchSubscriptions(updatedSince: nil, realm: realm) {
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

        client.fetchSubscriptions(updatedSince: nil, realm: realm) {
            if realm.objects(Subscription.self).count == 2 {
                expectation.fulfill()
            }
        }

        wait(for: [expectation], timeout: 5)
    }
}
