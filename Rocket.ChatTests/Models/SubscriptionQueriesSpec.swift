//
//  SubscriptionQueriesSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 23/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class SubscriptionManagerQueriesSpec: XCTestCase {

    override func tearDown() {
        super.tearDown()
        Realm.clearDatabase()
    }

    func testFindByRoomId() throws {
        let sub1 = Subscription()
        sub1.identifier = "sub1-identifier"
        sub1.rid = "sub1-rid"

        let sub2 = Subscription()
        sub2.identifier = "sub2-identifier"
        sub2.rid = "sub2-rid"

        Realm.current?.execute({ realm in
            realm.add(sub1, update: true)
            realm.add(sub2, update: true)
        })

        XCTAssertEqual(Subscription.find(rid: "sub2-rid"), sub2)
        XCTAssertEqual(Subscription.find(rid: "sub1-rid"), sub1)
    }

    func testFindByNameAndType() throws {
        let sub1 = Subscription()
        sub1.identifier = "sub1-identifier"
        sub1.name = "sub1-name"
        sub1.type = .directMessage

        let sub2 = Subscription()
        sub2.identifier = "sub2-identifier"
        sub2.name = "sub2-name"
        sub2.type = .channel

        Realm.current?.execute({ realm in
            realm.add(sub1, update: true)
            realm.add(sub2, update: true)
        })

        XCTAssertEqual(Subscription.find(name: "sub1-name", subscriptionType: [.directMessage]), sub1)
        XCTAssertEqual(Subscription.find(name: "sub2-name", subscriptionType: [.channel]), sub2)
    }

    func testSetTemporaryMessagesFailed() {
        let user = User.testInstance()
        let sub = Subscription.testInstance()

        let msg1 = Message.testInstance("msg1")
        msg1.rid = sub.rid
        msg1.failed = false
        msg1.temporary = true
        msg1.userIdentifier = user.identifier

        let msg2 = Message.testInstance("msg2")
        msg2.rid = sub.rid
        msg2.failed = false
        msg2.temporary = true
        msg2.userIdentifier = user.identifier

        Realm.current?.execute({ realm in
            realm.add(user, update: true)
            realm.add(sub, update: true)
            realm.add(msg1, update: true)
            realm.add(msg2, update: true)
        })

        sub.setTemporaryMessagesFailed(user: user)

        XCTAssertTrue(msg1.failed)
        XCTAssertFalse(msg1.temporary)

        XCTAssertTrue(msg2.failed)
        XCTAssertFalse(msg2.temporary)
    }

}
