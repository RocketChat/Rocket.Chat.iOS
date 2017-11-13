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

class LoginServiceSpec: XCTestCase, RealmTestCase {
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
            \"identityPath\" : \"/oauth/userinfo\",
            \"buttonLabelColor\" : \"#FFFFFF\",
            \"tokenPath\" : \"/oauth/token\",
            \"usernameField\" : \"\"
        }
        """)

    func testFind() throws {
        let realm = testRealm()

        let github = LoginService()
        github.identifier = "githubid"
        github.service = "github"
        let google = LoginService()
        google.identifier = "googleid"
        google.service = "google"

        try realm.write {
            realm.add(github)
            realm.add(google)
        }

        XCTAssertEqual(LoginService.find(service: "github", realm: realm), github, "Finds LoginService correctly")
    }

    func testMap() {
        let loginService = LoginService()
        loginService.map(testJSON, realm: nil)

        XCTAssertEqual(loginService.mergeUsers, false)
        XCTAssertEqual(loginService.clientId, "NhT7feA98YvKj6v6p")
        XCTAssertEqual(loginService.scope, "openid")
        XCTAssertEqual(loginService.custom, true)
        XCTAssertEqual(loginService.authorizePath, "/oauth/authorize")
        XCTAssertEqual(loginService.serverURL, "https://open.rocket.chat")
        XCTAssertEqual(loginService.service, "openrocketchat")
        XCTAssertEqual(loginService.loginStyle, "popup")
        XCTAssertEqual(loginService.tokenSentVia, "header")
        XCTAssertEqual(loginService.buttonColor, "#13679A")
        XCTAssertEqual(loginService.buttonLabelText, "Open")
        XCTAssertEqual(loginService.identityPath, "/oauth/userinfo")
        XCTAssertEqual(loginService.buttonLabelColor, "#FFFFFF")
        XCTAssertEqual(loginService.tokenPath, "/oauth/token")
        XCTAssertEqual(loginService.usernameField, "")
    }
}
