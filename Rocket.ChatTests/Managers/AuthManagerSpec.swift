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

class AuthManagerSpec: XCTestCase {

    let realm = try! Realm()
    
    override func setUp() {
        super.setUp()

        // Clear all the Auth objects in Realm
        try! realm.write {
            for obj in realm.objects(Auth.self) {
                realm.delete(obj)
            }
        }
    }

}


// MARK: isAuthenticated method

extension AuthManagerSpec {
    
    func testIsAuthenticatedUserNotAuthenticated() {
        XCTAssert(AuthManager.isAuthenticated() == nil, "isAuthenticated returns nil for non authenticated users")
    }
    
    func testIsAuthenticatedUserAuthenticated() {
        let auth = Auth()
        auth.serverURL = "123"

        try! realm.write {
            realm.add(auth)
        }
        
        XCTAssert(AuthManager.isAuthenticated()?.serverURL == auth.serverURL, "isAuthenticated returns Auth instance")
    }
    
    func testIsAuthenticatedReturnsLastAccessed() {
        let auth1 = Auth()
        auth1.serverURL = "one"
        auth1.lastAccess = NSDate()
        
        let auth2 = Auth()
        auth2.serverURL = "two"
        auth2.lastAccess = NSDate(timeIntervalSince1970: 1)
        
        try! realm.write {
            realm.add(auth1)
            realm.add(auth2)
        }
        
        XCTAssert(AuthManager.isAuthenticated()?.serverURL == auth1.serverURL, "isAuthenticated returns the latests Auth instance")
    }

}
