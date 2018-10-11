//
//  APIExtensionsSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class APIExtensionsSpec: XCTestCase {
    func testCurrent() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        var auth = Auth.testInstance()

        realm.execute({ realm in
            realm.add(auth)
        })

        var api = API.current(realm: realm)

        XCTAssertEqual(api?.userId, "auth-userid")
        XCTAssertEqual(api?.authToken, "auth-token")
        XCTAssertEqual(api?.version, Version(1, 2, 3))

        Realm.execute({ realm in
            auth.serverVersion = "invalid"
            realm.add(auth, update: true)
        })

        api = API.current(realm: realm)
        XCTAssertEqual(api?.version, Version.zero)

        auth = Auth()
        api = API.current(realm: realm)

        XCTAssertNotNil(api)

        auth = Auth()
        api = API.current(realm: nil)

        XCTAssertNil(api)
    }
}
