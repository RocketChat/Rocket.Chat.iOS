//
//  SpotlightClientSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 4/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON
import RealmSwift

@testable import Rocket_Chat

// swiftlint:disable function_body_length
class SpotlightClientSpec: XCTestCase {

    override func tearDown() {
        super.tearDown()
        Realm.clearDatabase()
    }

    func testSearch() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        let api = MockAPI()
        let client = SpotlightClient(api: api)

        api.nextResult = JSON([
            "rooms": [
                [
                    "name": "test_room_1",
                    "t": "c",
                    "_id": "sLJgxJzNZAff75Zyb"
                ],
                [
                    "name": "test_room_2",
                    "t": "c",
                    "_id": "XbPyi7qHbakmPFLce"
                ]
            ],
            "users": [
                [
                    "status": "offline",
                    "name": "Chris",
                    "_id": "AFug5MMXaK4ex57Ed",
                    "username": "test_user_1"
                ],
                [
                    "status": "offline",
                    "name": "Johannes",
                    "_id": "zE3fquAe88hbr6DXT",
                    "username": "test_user_2"
                ],
                [
                    "status": "offline",
                    "name": "Per Naucler",
                    "_id": "NYaznCEGzBKkHi2Jn",
                    "username": "test_user_3"
                ],
                [
                    "status": "offline",
                    "name": "a5555",
                    "_id": "vEKyxkLBaXSXm6NZ7",
                    "username": "test_user_4"
                ],
                [
                    "status": "offline",
                    "name": "test4",
                    "_id": "95tQnbrTiX7uWaTGi",
                    "username": "test_user_5"
                ]
            ],
            "success": true
        ])

        let expectation = XCTestExpectation(description: "number of subscriptions is correct")

        client.search(query: "test", realm: realm, completion: { response, _ in
            guard let response = response else {
                return
            }

            let rooms: [JSON] = response["rooms"].arrayValue
            let users: [JSON] = response["users"].arrayValue

            if (rooms.count + users.count) == 7 && realm.objects(Subscription.self).count == 7 {
                expectation.fulfill()
            }
        })

        wait(for: [expectation], timeout: 10)
    }
}
