//
//  SubscriptionQueriesSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 23/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class SubscriptionManagerQueriesSpec: XCTestCase, RealmTestCase {

    func testFindByRoomId() throws {
        let realm = testRealm()

        let sub1 = Subscription()
        sub1.identifier = "sub1-identifier"
        sub1.rid = "sub1-rid"

        let sub2 = Subscription()
        sub2.identifier = "sub2-identifier"
        sub2.rid = "sub2-rid"

        realm.execute({ _ in
            realm.add(sub1)
            realm.add(sub2)
        })

        XCTAssertEqual(Subscription.find(rid: "sub2-rid", realm: realm), sub2)
        XCTAssertEqual(Subscription.find(rid: "sub1-rid", realm: realm), sub1)
    }

    func testFindByNameAndType() throws {
        let realm = testRealm()

        let sub1 = Subscription()
        sub1.identifier = "sub1-identifier"
        sub1.name = "sub1-name"
        sub1.type = .directMessage

        let sub2 = Subscription()
        sub2.identifier = "sub2-identifier"
        sub2.name = "sub2-name"
        sub2.type = .channel

        realm.execute({ _ in
            realm.add(sub1)
            realm.add(sub2)
        })

        XCTAssertEqual(Subscription.find(name: "sub1-name", subscriptionType: [.directMessage], realm: realm), sub1)
        XCTAssertEqual(Subscription.find(name: "sub2-name", subscriptionType: [.channel], realm: realm), sub2)
    }

    func testSetTemporaryMessagesFailed() {
        let realm = testRealm()

        let user = User.testInstance()
        let sub = Subscription.testInstance()

        let msg1 = Message.testInstance("msg1")
        msg1.subscription = sub
        msg1.failed = false
        msg1.temporary = true
        msg1.user = user

        let msg2 = Message.testInstance("msg2")
        msg2.subscription = sub
        msg2.failed = false
        msg2.temporary = true
        msg2.user = user

        realm.execute({ _ in
            realm.add(sub, update: true)
            realm.add(msg1, update: true)
            realm.add(msg2, update: true)
        })

        sub.setTemporaryMessagesFailed(user: user)

        XCTAssert(msg1.failed == true)
        XCTAssert(msg1.temporary == false)

        XCTAssert(msg2.failed == true)
        XCTAssert(msg2.temporary == false)
    }

}
