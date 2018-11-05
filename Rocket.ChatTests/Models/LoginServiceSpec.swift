//
//  LoginServiceSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 10/23/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

extension LoginService {
    static func testInstance() -> LoginService {
        let loginService = LoginService()
        loginService.service = "github"
        loginService.scope = "user"
        loginService.serverUrl = "https://github.com"
        loginService.tokenPath = "/login/oauth/access_token"
        loginService.authorizePath = "/login/oauth/authorize"
        loginService.clientId = "client-id"
        return loginService
    }
}

class LoginServiceSpec: XCTestCase {
    let testJSON = JSON(parseJSON: """
        {
            \"mergeUsers\" : false,
            \"clientId\" : \"NhT7feA98YvKj6v6p\",
            \"scope\" : \"openid\",
            \"custom\" : true,
            \"authorizePath\" : \"/oauth/authorize\",
            \"serverURL\" : \"https://open.rocket.chat\",
            \"service\" : \"openrocketchat\",
            \"loginStyle\" : \"popup\",
            \"tokenSentVia\" : \"header\",
            \"buttonColor\" : \"#13679A\",
            \"buttonLabelText\" : \"Open\",
            \"buttonLabelColor\" : \"#FFFFFF\",
            \"tokenPath\" : \"/oauth/token\",
            \"usernameField\" : \"\"
        }
        """)

    func testFind() throws {
        let github = LoginService()
        github.identifier = "githubid"
        github.service = "github"

        let google = LoginService()
        google.identifier = "googleid"
        google.service = "google"

        Realm.execute({ realm in
            realm.add(github)
            realm.add(google)
        })

        XCTAssertEqual(LoginService.find(service: "github"), github, "Finds LoginService correctly")
    }

    func testMap() {
        let loginService = LoginService()
        loginService.map(testJSON, realm: nil)

        XCTAssertEqual(loginService.mergeUsers, false)
        XCTAssertEqual(loginService.clientId, "NhT7feA98YvKj6v6p")
        XCTAssertEqual(loginService.scope, "openid")
        XCTAssertEqual(loginService.custom, true)
        XCTAssertEqual(loginService.authorizePath, "/oauth/authorize")
        XCTAssertEqual(loginService.serverUrl, "https://open.rocket.chat")
        XCTAssertEqual(loginService.service, "openrocketchat")
        XCTAssertEqual(loginService.loginStyle, "popup")
        XCTAssertEqual(loginService.tokenSentVia, "header")
        XCTAssertEqual(loginService.buttonColor, "#13679A")
        XCTAssertEqual(loginService.buttonLabelText, "Open")
        XCTAssertEqual(loginService.buttonLabelColor, "#FFFFFF")
        XCTAssertEqual(loginService.tokenPath, "/oauth/token")
        XCTAssertEqual(loginService.usernameField, "")
    }

    func testAuthorizeUrl() {
        let service = LoginService()
        service.serverUrl = "https://open.rocket.chat/"
        service.authorizePath = "authorize_path"

        XCTAssertEqual(service.authorizeUrl, "https://open.rocket.chat/authorize_path")

        service.authorizePath = nil

        XCTAssertNil(service.authorizeUrl, "https://open.rocket.chat/authorize_path")
    }

    func testAccessTokenUrl() {
        let service = LoginService()
        service.serverUrl = "https://open.rocket.chat/"
        service.tokenPath = "token_path"

        XCTAssertEqual(service.accessTokenUrl, "https://open.rocket.chat/token_path")

        service.tokenPath = nil

        XCTAssertNil(service.accessTokenUrl, "https://open.rocket.chat/token_path")
    }
}
