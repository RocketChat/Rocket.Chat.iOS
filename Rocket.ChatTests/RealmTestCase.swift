//
//  RealmTestCase.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 11/9/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

@testable import Rocket_Chat

protocol RealmTestCase {
    func testRealm() -> Realm
}

extension RealmTestCase {
    func testRealm() -> Realm {
        // swiftlint:disable:next force_try
        return try! Realm(configuration: Realm.Configuration(inMemoryIdentifier: String.random(40)))
    }
}
