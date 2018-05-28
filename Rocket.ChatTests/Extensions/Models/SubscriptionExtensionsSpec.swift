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

    func testLinkingObjectsFilterByName() {
        let realm = testRealm()

        let auth = Auth.testInstance()

        let sub1 = Subscription.testInstance("sub1")
        sub1.auth = auth
        let sub2 = Subscription.testInstance("sub2")
        sub2.auth = auth

        try? realm.write {
            realm.add(sub1, update: true)
            realm.add(sub2, update: true)
            realm.add(auth, update: true)
        }

        let objects = auth.subscriptions.filterBy(name: "sub1")

        XCTAssert(objects.count == 1)
        XCTAssert(objects.first == sub1)

        let objectsUppercase = auth.subscriptions.filterBy(name: "SUB1")

        XCTAssert(objectsUppercase.count == 1)
        XCTAssert(objectsUppercase.first == sub1)
    }

}

// MARK: Information Viewing Options

extension SubscriptionExtensionsSpec {

    func testCanViewMentionsListDirectMessage() {
        let subscription = Subscription()
        subscription.type = .directMessage
        subscription.identifier = "1"

        XCTAssertFalse(subscription.canViewMentionsList)
    }

    func testCanViewMentionsListChannel() {
        let subscription = Subscription()
        subscription.type = .channel
        subscription.identifier = "1"

        XCTAssertTrue(subscription.canViewMentionsList)
    }

    func testCanViewMentionsListGroup() {
        let subscription = Subscription()
        subscription.type = .group
        subscription.identifier = "1"

        XCTAssertTrue(subscription.canViewMentionsList)
    }

}
