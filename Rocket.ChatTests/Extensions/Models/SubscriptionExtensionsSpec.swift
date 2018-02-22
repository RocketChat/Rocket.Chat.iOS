//
//  SubscriptionExtensionsSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 2/21/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import XCTest

@testable import Rocket_Chat

class SubscriptionExtensionsSpec: XCTestCase, RealmTestCase {
    func testFilterByName() {
        let realm = testRealm()

        let sub1 = Subscription.testInstance("sub1")
        let sub2 = Subscription.testInstance("sub2")

        try? realm.write {
            realm.add(sub1, update: true)
            realm.add(sub2, update: true)
        }

        let objects = realm.objects(Subscription.self).filterBy(name: "sub1")

        XCTAssert(objects.count == 1)
        XCTAssert(objects.first == sub1)

        let objectsUppercase = realm.objects(Subscription.self).filterBy(name: "SUB1")

        XCTAssert(objectsUppercase.count == 1)
        XCTAssert(objectsUppercase.first == sub1)
    }

    func testSortedByLastSeen() {
        let realm = testRealm()

        let sub1 = Subscription.testInstance("sub1")
        sub1.lastSeen = Date() - 1
        let sub2 = Subscription.testInstance("sub2")
        sub2.lastSeen = Date()

        try? realm.write {
            realm.add(sub1, update: true)
            realm.add(sub2, update: true)
        }

        let objects = realm.objects(Subscription.self).sortedByLastSeen()

        XCTAssert(objects.count == 2)
        XCTAssert(objects.first == sub2)
        XCTAssert(objects.last == sub1)
    }
}
