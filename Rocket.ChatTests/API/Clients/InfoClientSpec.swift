//
//  InfoClientSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON

@testable import Rocket_Chat

class InfoClientSpec: XCTestCase, RealmTestCase {
    func testFetchInfo() {
        let api = MockAPI()
        let realm = testRealm()
        let client = InfoClient(api: api)

        api.nextResult = JSON([
            "info": [
                "version": "0.59.3"
            ],
            "success": "true"
        ])

        realm.execute({ _ in
            realm.add(Auth.testInstance())
        })

        client.fetchInfo(realm: realm)
        XCTAssertEqual(AuthManager.isAuthenticated(realm: realm)?.serverVersion, "0.59.3")
    }

    //swiftlint:disable function_body_length
    func testFetchLoginServices() {
        let api = MockAPI()
        let realm = testRealm()
        let client = InfoClient(api: api)

        api.nextResult = JSON([
            "services": [
                [
                    "_id": "ooGRhWvEPrLx9vPFB",
                    "service": "open",
                    "clientId": "h8K3pqagWgqxBE2cp",
                    "custom": true,
                    "serverURL": "https://open.rocket.chat",
                    "tokenPath": "/oauth/token",
                    "identityPath": "/api/v1/me",
                    "authorizePath": "/oauth/authorize",
                    "scope": "openid",
                    "buttonLabelText": "open",
                    "buttonLabelColor": "#FFFFFF",
                    "loginStyle": "popup",
                    "buttonColor": "#13679A",
                    "tokenSentVia": "payload",
                    "identityTokenSentVia": nil,
                    "usernameField": "username",
                    "mergeUsers": true
                ],
                [
                    "_id": "AKSJHdjkasdh",
                    "service": "cardoso",
                    "clientId": "h8K3pqagWgqxBE2cp",
                    "custom": true,
                    "serverURL": "https://cardoso.rocket.chat",
                    "tokenPath": "/oauth/token",
                    "identityPath": "/api/v1/me",
                    "authorizePath": "/oauth/authorize",
                    "scope": "openid",
                    "buttonLabelText": "open",
                    "buttonLabelColor": "#FFFFFF",
                    "loginStyle": "popup",
                    "buttonColor": "#13679A",
                    "tokenSentVia": "payload",
                    "identityTokenSentVia": nil,
                    "usernameField": "username",
                    "mergeUsers": true
                ]],
            "success": true
        ])

        realm.execute({ _ in
            realm.add(Auth.testInstance())
        })

        client.fetchLoginServices(realm: realm)
        XCTAssertEqual(realm.objects(LoginService.self).count, 2)
    }

    func testFetchPermissions() {
        let api = MockAPI()
        let realm = testRealm()
        let client = InfoClient(api: api)

        api.nextResult = JSON([
            [
                "_id": "snippet-message",
                "roles": [
                    "owner",
                    "moderator",
                    "admin"
                ]
            ],
            [
                "_id": "access-permissions",
                "roles": [
                    "admin"
                ]
            ]
        ])

        client.fetchPermissions(realm: realm)
        XCTAssertEqual(realm.objects(Permission.self).count, 2)
    }
}
