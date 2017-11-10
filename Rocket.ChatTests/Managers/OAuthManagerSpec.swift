//
//  OAuthManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 10/23/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import SwiftyJSON
import RealmSwift

@testable import Rocket_Chat

class OAuthManagerSpec: XCTestCase {

    func testOAuthCredentials() {
        let json = JSON([
            "credentialSecret": "dj_4JCx3Ix8fL4IEPnH-redacted",
            "credentialToken": "blvELQFjdP8q5u6Je0ceTYDChredacted"
        ])

        guard let credentials = OAuthCredentials(json: json) else {
            return XCTFail("credentials is not nil")
        }

        XCTAssertEqual(credentials.secret, "dj_4JCx3Ix8fL4IEPnH-redacted", "token is correct")
        XCTAssertEqual(credentials.token, "blvELQFjdP8q5u6Je0ceTYDChredacted", "secret is correct")
    }

    func testOAuthCredentialsFail() {
        let json = JSON([
            "credentialSecret": "dj_4JCx3Ix8fL4IEPnH-redacted"
            ])

        XCTAssertNil(OAuthCredentials(json: json), "credentials is nil")
    }

    func testCallbackURL() {
        let loginService = LoginService()
        loginService.service = "github"

        let serverURL: URL! = URL(string: "https://open.rocket.chat")
        let expectedURL: URL! = URL(string: "https://open.rocket.chat/_oauth/github")

        XCTAssertEqual(OAuthManager.callbackURL(for: loginService, server: serverURL), expectedURL, "callbackURL returns expected url")

        let malformedServerURL: URL! = URL(string: "open.rocket.chat")

        XCTAssertNil(OAuthManager.callbackURL(for: loginService, server: malformedServerURL), "callbackURL returns nil with malformed server URL")
    }

    func testState() {
        XCTAssertNotNil(OAuthManager.state(), "returns non nil state")
    }
}
