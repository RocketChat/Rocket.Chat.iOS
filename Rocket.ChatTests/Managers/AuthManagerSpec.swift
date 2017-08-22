//
//  AuthManagerSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class AuthManagerSpec: XCTestCase, AuthManagerInjected {


    override func setUp() {
        super.setUp()

        // Clear all the Auth objects in Realm
        Realm.executeOnMainThread({ realm in
            for obj in realm.objects(Auth.self) {
                realm.delete(obj)
            }
        })
    }

}

// MARK: isAuthenticated method

extension AuthManagerSpec {

    func testIsAuthenticatedUserNotAuthenticated() {
        XCTAssert(authManager.isAuthenticated() == nil, "isAuthenticated returns nil for non authenticated users")
    }

    func testIsAuthenticatedUserAuthenticated() {
        Realm.executeOnMainThread({ realm in
            let auth = Auth()
            auth.serverURL = "ws://123.cc"

            realm.add(auth)

            XCTAssert(self.authManager.isAuthenticated()?.serverURL == auth.serverURL, "isAuthenticated returns Auth instance")
        })
    }

    func testIsAuthenticatedReturnsLastAccessed() {
        Realm.executeOnMainThread({ realm in
            let auth1 = Auth()
            auth1.serverURL = "ws://one.cc"
            auth1.lastAccess = Date()

            let auth2 = Auth()
            auth2.serverURL = "ws://two.cc"
            auth2.lastAccess = Date(timeIntervalSince1970: 1)

            realm.add(auth1)
            realm.add(auth2)

            XCTAssert(self.authManager.isAuthenticated()?.serverURL == auth1.serverURL, "isAuthenticated returns the latests Auth instance")
        })
    }

}
