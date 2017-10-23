//
//  RealmTest.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 10/23/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import RealmSwift

class RealmTestCase: XCTestCase {
    func createTestRealm() throws -> Realm {
        return try Realm(configuration: Realm.Configuration(inMemoryIdentifier: String.random(40)))
    }
}
