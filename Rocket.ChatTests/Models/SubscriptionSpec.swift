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
    static func testInstance(_ name: String = "subscription") -> Subscription {
        let subscription = Subscription()
        subscription.auth = Auth.testInstance()
        subscription.rid = "\(name)-rid"
        subscription.name = "\(name)-name"
        subscription.identifier = "\(name)-identifier"
        subscription.open = true
        return subscription
    }
}

// swiftlint:disable type_body_length file_length
class SubscriptionSpec: XCTestCase {

    override func tearDown() {
        super.tearDown()
        Realm.clearDatabase()
    }

    func testSubscriptionObject() {
        Realm.execute({ realm in
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
            XCTAssertEqual(results.count, 1, "Subscription object was created with success")
            XCTAssertEqual(first?.identifier, "subs-from-data", "Subscription object was created with success")
            XCTAssertEqual(auth.subscriptions.first?.identifier, first?.identifier, "Auth relationship with Subscription is OK")
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

        Realm.execute({ realm in
            let auth = Auth()
            auth.serverURL = "http://foo.bar.baz"

            let subscription = Subscription()
            subscription.map(object, realm: realm)
            subscription.auth = auth

            realm.add(subscription, update: true)

            let results = realm.objects(Subscription.self)
            let first = results.first
            XCTAssertEqual(results.count, 1, "Subscription object was created with success")
            XCTAssertEqual(first?.identifier, "subs-from-json-1", "Subscription object was created with success")
            XCTAssertEqual(auth.subscriptions.first?.identifier, first?.identifier, "Auth relationship with Subscription is OK")
        })
    }

    func testMapLastSeenDateInteger() {
        let interval = 123456789
        let object = JSON([
            "_id": "identifier",
            "ls": ["$date": interval]
        ])

        let subscription = Subscription()
        subscription.map(object, realm: nil)
        XCTAssertEqual(subscription.lastSeen, Date.dateFromInterval(123456789))
    }

    func testMapLastSeenDateString() {
        let lastSeen = "2018-05-16T13:08:39.118Z"
        let object = JSON([
            "_id": "identifier",
            "ls": lastSeen
        ])

        let subscription = Subscription()
        subscription.map(object, realm: nil)
        XCTAssertEqual(subscription.lastSeen, Date.dateFromString(lastSeen))
    }

    func testMapLastSeenUpdated() {
        let lastSeen = "2018-05-16T13:08:39.118Z"
        let interval = 123456789

        let object1 = JSON([
            "_id": "identifier",
            "ls": ["$date": interval]
        ])

        let object2 = JSON([
            "_id": "identifier",
            "ls": lastSeen
        ])

        let subscription = Subscription()
        subscription.map(object1, realm: nil)
        subscription.map(object2, realm: nil)
        XCTAssertEqual(subscription.lastSeen, Date.dateFromString(lastSeen))
    }

    func testMapLastSeenUpdatedEmpty() {
        let lastSeen = "2018-05-16T13:08:39.118Z"

        let object1 = JSON([
            "_id": "identifier",
            "ls": lastSeen
        ])

        let object2 = JSON([
            "_id": "identifier"
        ])

        let subscription = Subscription()
        subscription.map(object1, realm: nil)
        subscription.map(object2, realm: nil)
        XCTAssertEqual(subscription.lastSeen, Date.dateFromString(lastSeen))
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
            "broadcast": true,
            "description": "room-description",
            "announcement": "room-announcement"
        ])

        let subscription = Subscription()

        subscription.mapRoom(object, realm: nil)

        XCTAssertEqual(subscription.roomTopic, "room-topic")
        XCTAssertEqual(subscription.roomDescription, "room-description")
        XCTAssertEqual(subscription.roomAnnouncement, "room-announcement")
        XCTAssertEqual(subscription.roomReadOnly, true)
        XCTAssertEqual(subscription.roomBroadcast, true)
        XCTAssertEqual(subscription.roomOwnerId, "user-id")
    }

    func testMapRoomReadOnlyFalse() {
        let object = JSON([
            "_id": "room-id",
            "t": "c",
            "name": "room-name",
            "ro": false
        ])

        let subscription = Subscription()
        subscription.mapRoom(object, realm: nil)

        XCTAssertEqual(subscription.roomReadOnly, false)
    }

    func testMapRoomReadOnlyEmpty() {
        let object = JSON([
            "_id": "room-id",
            "t": "c",
            "name": "room-name"
        ])

        let subscription = Subscription()
        subscription.mapRoom(object, realm: nil)

        XCTAssertEqual(subscription.roomReadOnly, false)
    }

    func testMapRoomBroadcastFalse() {
        let object = JSON([
            "_id": "room-id",
            "t": "c",
            "name": "room-name",
            "broadcast": false
        ])

        let subscription = Subscription()
        subscription.mapRoom(object, realm: nil)

        XCTAssertEqual(subscription.roomBroadcast, false)
    }

    func testMapRoomBroadcastEmpty() {
        let object = JSON([
            "_id": "room-id",
            "t": "c",
            "name": "room-name"
        ])

        let subscription = Subscription()
        subscription.mapRoom(object, realm: nil)

        XCTAssertEqual(subscription.roomBroadcast, false)
    }

    func testMapRoomLastMessage() {
        let messageDateInterval = Double(1480377601)
        let messageIdentifier = "NX5dO115rrYbnUBrxA"
        let object = JSON([
            "_id": "room-id",
            "t": "c",
            "name": "room-name",
            "lastMessage": [
                "u": [
                    "name": "Rafael Kellermann Streit",
                    "username": "rafaelks.test.2",
                    "_id": "8WmDXhgXSyKeGrF5L"
                ],
                "_id": messageIdentifier,
                "msg": "Testing.",
                "ts": [ "$date": messageDateInterval ]
            ]
        ])

        let subscription = Subscription.testInstance()

        Realm.execute({ (realm) in
            subscription.mapRoom(object, realm: realm)
            realm.add(subscription, update: true)
        })

        XCTAssertEqual(subscription.roomLastMessageDate, Date.dateFromInterval(messageDateInterval))
        XCTAssertEqual(subscription.roomLastMessageText, "rafaelks.test.2: Testing.")
        XCTAssertEqual(subscription.roomLastMessage?.identifier, messageIdentifier)
    }

    func testMapRoomLastMessageWontUpdate() {
        let messageDateInterval = Double(1480377601)
        let messageIdentifier = "NX5dO115rrYbnUBrxA"
        let subscription = Subscription()

        let object1 = JSON([
            "_id": "room-id",
            "t": "c",
            "name": "room-name",
            "lastMessage": [
                "u": [
                    "name": "Rafael Kellermann Streit",
                    "username": "rafaelks.test.2",
                    "_id": "8WmDXhgXSyKeGrF5L"
                ],
                "_id": messageIdentifier,
                "msg": "Testing.",
                "ts": [ "$date": messageDateInterval ]
            ]
        ])

        Realm.execute({ (realm) in
            subscription.mapRoom(object1, realm: realm)
        })

        XCTAssertEqual(subscription.roomLastMessageDate, Date.dateFromInterval(messageDateInterval))
        XCTAssertEqual(subscription.roomLastMessageText, "rafaelks.test.2: Testing.")
        XCTAssertEqual(subscription.roomLastMessage?.identifier, messageIdentifier)

        let object2 = JSON([
            "_id": "room-id",
            "t": "c",
            "name": "room-name",
            "lastMessage": [
                "u": [
                    "name": "Rafael Kellermann Streit",
                    "username": "rafaelks.test.2",
                    "_id": "8WmDXhgXSyKeGrF5L"
                ],
                "_id": messageIdentifier,
                "msg": "Testing message update, without changing date.",
                "ts": [ "$date": messageDateInterval ]
            ]
        ])

        Realm.execute({ (realm) in
            subscription.mapRoom(object2, realm: realm)
        })

        XCTAssertEqual(subscription.roomLastMessageDate, Date.dateFromInterval(messageDateInterval))
        XCTAssertEqual(subscription.roomLastMessageText, "rafaelks.test.2: Testing.")
        XCTAssertEqual(subscription.roomLastMessage?.identifier, messageIdentifier)
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

        Realm.execute({ realm in
            realm.add(user)
        })

        XCTAssertEqual(subscription.roomOwner, user, "roomOwner is correct")
    }

    func testDirectMessageUser() {
        let user = User()
        user.identifier = "other-user-id"

        let subscription = Subscription()
        subscription.otherUserId = user.identifier

        Realm.execute({ realm in
            realm.add(user)
        })

        XCTAssertEqual(subscription.directMessageUser, user, "directMessageUser is correct")
    }

    func testDiscussionCheckTrue() {
        let subscription = Subscription()
        subscription.type = .group
        subscription.rid = "123"
        subscription.prid = "parentRid"

        XCTAssertTrue(subscription.isDiscussion, "subscription is a discussion")
    }

    func testDiscussionCheckFalse() {
        let subscription = Subscription()
        subscription.type = .channel
        subscription.rid = "123"
        subscription.prid = ""

        XCTAssertFalse(subscription.isDiscussion, "subscription is a discussion")
    }
}
