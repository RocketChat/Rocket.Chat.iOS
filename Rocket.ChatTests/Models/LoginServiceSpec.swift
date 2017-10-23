//
//  LoginServiceSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 10/23/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class LoginServiceSpec: XCTestCase {
    func testFind() throws {
        let realm = try Realm(configuration: Realm.Configuration(inMemoryIdentifier: String.random(40)))

        try realm.write {
            let github = LoginService()
            github.service = "github"
            let google = LoginService()
            google.service = "google"

            realm.add(github)
            realm.add(google)
        }

        XCTAssertEqual(LoginService.find(service: "github", realm: realm), loginService, "Finds LoginService correctly")
    }
}
