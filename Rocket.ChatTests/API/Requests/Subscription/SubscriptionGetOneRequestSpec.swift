//
//  SubscriptionGetOneRequestSpec.swift
//  Rocket.ChatTests
//
//  Created by Artur Rymarz on 16.04.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class SubscriptionGetOneRequestSpec: APISpec {

    func testRequest() {
        let preRequest = SubscriptionGetOneRequest(roomId: "5of4weEXaH7yncxz9")

        guard let request = preRequest.request(for: api) else {
            return XCTFail("request is not nil")
        }

        let url = api.host.appendingPathComponent(preRequest.path)
        var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        urlComponents?.query = "roomId=5of4weEXaH7yncxz9"

        XCTAssertEqual(request.url, urlComponents?.url, "url is correct")
        XCTAssertEqual(request.httpMethod, "GET", "http method is correct")
    }

    //swiftlint:disable function_body_length
    func testProperties() {
        let jsonString = """
            {
                "subscription": {
                    "_id": "Rd8qisB7G4tF4Fibu",
                    "open": true,
                    "alert": false,
                    "unread": 0,
                    "userMentions": 0,
                    "groupMentions": 0,
                    "ts": "2018-03-12T17:52:13.041Z",
                    "rid": "5of4weEXaH7yncxz9",
                    "name": "test",
                    "fname": "test",
                    "customFields": {},
                    "t": "p",
                    "u": {
                        "_id": "47cRd58HnWwpqxhaZ",
                        "username": "rocket.cat",
                        "name": null
                    },
                    "ls": "2018-03-12T17:52:13.041Z",
                    "_updatedAt": "2018-03-13T19:36:27.696Z",
                    "roles": [
                        "owner"
                    ],
                    "disableNotifications": false,
                    "desktopNotifications": "nothing",
                    "emailNotifications": "nothing",
                    "audioNotificationValue": "beep",
                    "desktopNotificationDuration": 2,
                    "audioNotifications": "all",
                    "mobilePushNotifications": "mentions",
                    "f": false,
                    "meta": {
                        "revision": 0,
                        "created": 1521051029632,
                        "version": 0
                    }
                },
                "success": true
            }
        """

        let json = JSON(parseJSON: jsonString)

        let result = SubscriptionGetOneResource(raw: json)

        guard let subscription = result.subscription else {
            XCTAssertNotNil(result.subscription)
            return
        }

        XCTAssertFalse(subscription.disableNotifications)
        XCTAssertEqual(subscription.desktopNotifications, .nothing)
        XCTAssertEqual(subscription.emailNotifications, .nothing)
        XCTAssertEqual(subscription.audioNotificationValue, .beep)
        XCTAssertEqual(subscription.desktopNotificationDuration, 2)
        XCTAssertEqual(subscription.audioNotifications, .all)
        XCTAssertEqual(subscription.mobilePushNotifications, .mentions)
    }

}
