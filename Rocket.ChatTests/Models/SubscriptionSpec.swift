//
//  SubscriptionSpec.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift
import SwiftyJSON

@testable import Rocket_Chat

// MARK: Test Instance

extension Subscription {
    static func testInstance() -> Subscription {
        let subscription = Subscription()
        subscription.auth = Auth.testInstance()
        subscription.rid = "subscription-rid"
        subscription.name = "subscription-name"
        subscription.identifier = "subscription-identifier"
        return subscription
    }
}

class SubscriptionSpec: XCTestCase {

    override func setUp() {
        super.setUp()

        var uniqueConfiguration = Realm.Configuration.defaultConfiguration
        uniqueConfiguration.inMemoryIdentifier = NSUUID().uuidString
        Realm.Configuration.defaultConfiguration = uniqueConfiguration

        Realm.executeOnMainThread({ (realm) in
            realm.deleteAll()
        })
    }

    func testSubscriptionObject() {
        Realm.executeOnMainThread({ realm in
            let auth = Auth()
            auth.serverURL = "http://foo.bar.baz"

            let object = Subscription()
            object.auth = auth
            object.identifier = "subs-from-data"
            object.rid = "subs-from-data-rid"
            object.name = "Foo Bar Baz"
            object.unread = 10
            object.open = false
            object.alert = true
            object.favorite = true
            object.createdAt = Date()
            object.lastSeen = Date()

            realm.add(object, update: true)

            let results = realm.objects(Subscription.self)
            let first = results.first
            XCTAssert(results.count == 1, "Subscription object was created with success")
            XCTAssert(first?.identifier == "subs-from-data", "Subscription object was created with success")
            XCTAssert(auth.subscriptions.first?.identifier == first?.identifier, "Auth relationship with Subscription is OK")
        })
    }

    func testSubscriptionObjectFromJSON() {
        let object = JSON([
            "_id": "subs-from-json-1",
            "rid": "subs-from-json-1-rid",
            "name": "Foo Bar Baz",
            "unread": 0,
            "open": false,
            "alert": true,
            "f": false,
            "ts": ["$date": 123456789],
            "ls": ["$date": 123456789]
        ])

        Realm.executeOnMainThread({ realm in
            let auth = Auth()
            auth.serverURL = "http://foo.bar.baz"

            let subscription = Subscription()
            subscription.map(object, realm: realm)
            subscription.auth = auth

            realm.add(subscription, update: true)

            let results = realm.objects(Subscription.self)
            let first = results.first
            XCTAssert(results.count == 1, "Subscription object was created with success")
            XCTAssert(first?.identifier == "subs-from-json-1", "Subscription object was created with success")
            XCTAssert(auth.subscriptions.first?.identifier == first?.identifier, "Auth relationship with Subscription is OK")
        })
    }

    func testMapRoom() {
        let object = JSON([
            "_id": "room-id",
            "t": "c",
            "name": "room-name",
            "u": [ "_id": "user-id", "username": "username" ],
            "topic": "room-topic",
            "muted": [ "username" ],
            "jitsiTimeout": [ "$date": 1480377601 ],
            "ro": true,
            "description": "room-description"
        ])

        let subscription = Subscription()

        subscription.mapRoom(object)

        XCTAssertEqual(subscription.roomTopic, "room-topic")
        XCTAssertEqual(subscription.roomDescription, "room-description")
        XCTAssertEqual(subscription.roomReadOnly, true)
        XCTAssertEqual(subscription.roomOwnerId, "user-id")
    }

    func testSubscriptionDisplayNameHonorFullnameSettings() {
        let settings = AuthSettings()
        settings.useUserRealName = false

        AuthSettingsManager.shared.internalSettings = settings

        // Direct Messages
        let directMessage = Subscription()
        directMessage.name = "direct.message"
        directMessage.fname = "DM"
        directMessage.privateType = "d"

        XCTAssertNotEqual(directMessage.displayName(), "DM", "Subscription.displayName() will return fname property")
        XCTAssertEqual(directMessage.displayName(), "direct.message", "Subscription.displayName() won't return name property")

        // Channels
        let channel = Subscription()
        channel.name = "channel"
        channel.fname = "CHANNEL"
        channel.privateType = "c"

        XCTAssertEqual(channel.displayName(), "channel", "Subscription.displayName() will always return name for channels")
        XCTAssertNotEqual(channel.displayName(), "CHANNEL", "Subscription.displayName() will always return name for channels")

        // Groups and Private Groups
        let group = Subscription()
        group.name = "group"
        group.fname = "GROUP"
        group.privateType = "p"

        XCTAssertEqual(group.displayName(), "group", "Subscription.displayName() will always return name for groups")
        XCTAssertNotEqual(group.displayName(), "GROUP", "Subscription.displayName() will always return name for groups")
    }

    func testSubscriptionDisplayNameHonorNameSettings() {
        let settings = AuthSettings()
        settings.useUserRealName = true

        AuthSettingsManager.shared.internalSettings = settings

        // Direct Messages
        let directMessage = Subscription()
        directMessage.name = "direct.message"
        directMessage.fname = "DM"
        directMessage.privateType = "d"

        XCTAssertEqual(directMessage.displayName(), "DM", "Subscription.displayName() will return fname property")
        XCTAssertNotEqual(directMessage.displayName(), "direct.message", "Subscription.displayName() won't return name property")

        // Channels
        let channel = Subscription()
        channel.name = "channel"
        channel.fname = "CHANNEL"
        channel.privateType = "c"

        XCTAssertEqual(channel.displayName(), "channel", "Subscription.displayName() will always return name for channels")
        XCTAssertNotEqual(channel.displayName(), "CHANNEL", "Subscription.displayName() will always return name for channels")

        // Groups and Private Groups
        let group = Subscription()
        group.name = "group"
        group.fname = "GROUP"
        group.privateType = "p"

        XCTAssertEqual(group.displayName(), "group", "Subscription.displayName() will always return name for groups")
        XCTAssertNotEqual(group.displayName(), "GROUP", "Subscription.displayName() will always return name for groups")
    }

    func testSubscriptionDisplayChannelNameWithSpecialChars() {
        let settings = AuthSettings()
        settings.allowSpecialCharsOnRoomNames = true

        AuthSettingsManager.shared.internalSettings = settings

        // Channels
        let channel = Subscription()
        channel.name = "special-channel"
        channel.fname = "special channel"
        channel.privateType = "c"

        XCTAssertEqual(channel.displayName(), "special channel", "Subscription.displayName() will return fname for channels when 'allowSpecialCharsOnRoomNames' is enabled")
        XCTAssertNotEqual(channel.displayName(), "special-channel", "Subscription.displayName() will return fname for channels when 'allowSpecialCharsOnRoomNames' is enabled")

        // Groups and Private Groups
        let group = Subscription()
        group.name = "special-group"
        group.fname = "special group"
        group.privateType = "p"

        XCTAssertEqual(group.displayName(), "special group", "Subscription.displayName() will return fname for groups when 'allowSpecialCharsOnRoomNames' is enabled")
        XCTAssertNotEqual(group.displayName(), "special-group", "Subscription.displayName() will return fname for groups when 'allowSpecialCharsOnRoomNames' is enabled")
    }

    func testSubscriptionDisplayChannelNameWithoutSpecialChars() {
        let settings = AuthSettings()
        settings.allowSpecialCharsOnRoomNames = false

        AuthSettingsManager.shared.internalSettings = settings

        // Channels
        let channel = Subscription()
        channel.name = "special-channel"
        channel.fname = "special channel"
        channel.privateType = "c"

        XCTAssertEqual(channel.displayName(), "special-channel", "Subscription.displayName() will return name for channels when 'allowSpecialCharsOnRoomNames' is disabled")
        XCTAssertNotEqual(channel.displayName(), "special channel", "Subscription.displayName() will return name for channels when 'allowSpecialCharsOnRoomNames' is disabled")

        // Groups and Private Groups
        let group = Subscription()
        group.name = "special-group"
        group.fname = "special group"
        group.privateType = "p"

        XCTAssertEqual(group.displayName(), "special-group", "Subscription.displayName() will return name for groups when 'allowSpecialCharsOnRoomNames' is disabled")
        XCTAssertNotEqual(group.displayName(), "special group", "Subscription.displayName() will return name for groups when 'allowSpecialCharsOnRoomNames' is disabled")
    }

    func testRoomOwner() {
        let user = User()
        user.identifier = "room-owner-id"

        let subscription = Subscription()
        subscription.roomOwnerId = user.identifier

        Realm.executeOnMainThread { realm in
            realm.add(user)
        }

        XCTAssertEqual(subscription.roomOwner, user, "roomOwner is correct")
    }

    func testDirectMessageUser() {
        let user = User()
        user.identifier = "other-user-id"

        let subscription = Subscription()
        subscription.otherUserId = user.identifier

        Realm.executeOnMainThread { realm in
            realm.add(user)
        }

        XCTAssertEqual(subscription.directMessageUser, user, "directMessageUser is correct")
    }
}

// MARK: Test Queries
extension SubscriptionSpec: RealmTestCase {
    func testFindByRoomId() throws {
        let realm = testRealm()

        let sub1 = Subscription()
        sub1.identifier = "sub1-identifier"
        sub1.rid = "sub1-rid"

        let sub2 = Subscription()
        sub2.identifier = "sub2-identifier"
        sub2.rid = "sub2-rid"

        try realm.write {
            realm.add(sub1)
            realm.add(sub2)
        }

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

        try realm.write {
            realm.add(sub1)
            realm.add(sub2)
        }

        XCTAssertEqual(Subscription.find(name: "sub1-name", subscriptionType: [.directMessage], realm: realm), sub1)
        XCTAssertEqual(Subscription.find(name: "sub2-name", subscriptionType: [.channel], realm: realm), sub2)
    }

    func testInitialSubscription() throws {
        let realm = testRealm()

        let auth = Auth.testInstance()

        let sub1 = Subscription()
        sub1.identifier = "sub1-identifier"
        sub1.rid = "sub1-rid"
        sub1.lastSeen = Date()
        sub1.auth = auth

        let sub2 = Subscription()
        sub2.identifier = "sub2-identifier"
        sub2.rid = "sub2-rid"
        sub2.lastSeen = Date().addingTimeInterval(-1.0)
        sub2.auth = auth

        try realm.write {
            realm.add(auth)
            realm.add(sub1)
            realm.add(sub2)
        }

        // if there's no last notification room id (user didn't launch app by tapping notification)
        XCTAssertEqual(Subscription.initialSubscription(auth: auth), sub1)

        PushManager.lastNotificationRoomId = "sub2-rid"

        // if there's no last notification room id (user launched app by tapping notification)
        XCTAssertEqual(Subscription.initialSubscription(auth: auth), sub2)
    }
}
