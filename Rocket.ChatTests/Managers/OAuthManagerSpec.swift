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

    func testCallbackUrl() {
        let loginService = LoginService()
        loginService.service = "github"

        let serverURL: URL! = URL(string: "https://open.rocket.chat")
        let expectedURL: URL! = URL(string: "https://open.rocket.chat/_oauth/github")

        XCTAssertEqual(
            OAuthManager.callbackUrl(for: loginService, server: serverURL),
            expectedURL,
            "callbackURL returns expected url"
        )
    }

    func testCallbackUrlWithPath() {
        let loginService = LoginService()
        loginService.service = "github"

        let serverURL: URL! = URL(string: "https://open.rocket.chat/path")
        let expectedURL: URL! = URL(string: "https://open.rocket.chat/path/_oauth/github")

        XCTAssertEqual(
            OAuthManager.callbackUrl(for: loginService, server: serverURL),
            expectedURL,
            "callbackURL returns expected url with path"
        )
    }

    func testCallbackUrlMalformed() {
        let loginService = LoginService()
        loginService.service = "github"

        let serverURL: URL! = URL(string: "open.rocket.chat")

        XCTAssertNil(
            OAuthManager.callbackUrl(for: loginService, server: serverURL),
            "callbackURL returns nil with malformed server URL"
        )
    }

    func testState() {
        XCTAssertNotNil(OAuthManager.state(), "returns non nil state")
    }

    func testOauthSwiftForLoginService() {
        let loginService = LoginService()
        loginService.serverUrl = "https://open.rocket.chat/"
        loginService.authorizePath = "authorize_path"
        loginService.tokenPath = "token_path"
        loginService.clientId = "client_id"

        XCTAssertNotNil(OAuthManager.oauthSwift(for: loginService), "oauthSwift is not nil")

        loginService.authorizePath = nil

        XCTAssertNil(OAuthManager.oauthSwift(for: loginService), "oauthSwift is nil")
    }

    func testCredentialsForUrlFragment() {
        let fragment = "%7B%22credentialToken%22:%22token%22,%22credentialSecret%22:%22secret%22%7D"

        let credentials = OAuthManager.credentialsForUrlFragment(fragment)

        XCTAssertEqual(credentials?.token, "token", "token is correct")
        XCTAssertEqual(credentials?.secret, "secret", "secret is correct")

        let malformedFragment = "%7B%22credentialToken%22:%22token%22,%22credentialSecret%22:%22secret%22%7"

        XCTAssertNil(OAuthManager.credentialsForUrlFragment(malformedFragment), "credentials is nil for malformed fragment")
    }

    func testAuthorizeWithInvalidLoginService() {
        let loginService = LoginService()

        let url: URL! = URL(string: "https://open.rocket.chat/")
        let valid = OAuthManager.authorize(loginService: loginService, at: url, viewController: UIViewController(), success: { _ in }, failure: { })

        XCTAssertFalse(valid)
    }

    func testAuthorizeWithValidLoginService() {
        let loginService = LoginService.testInstance()
        let url: URL! = URL(string: "https://open.rocket.chat")
        let valid = OAuthManager.authorize(loginService: loginService, at: url, viewController: UIViewController(), success: { _ in }, failure: { })

        XCTAssertTrue(valid)
    }
}
