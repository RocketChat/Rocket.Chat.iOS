//
//  SubscriptionExtensionsSpec.swift
//  Rocket.ChatTests
//
//  Created by Matheus Cardoso on 2/21/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import XCTest
import RealmSwift

@testable import Rocket_Chat

class SubscriptionExtensionsSpec: XCTestCase {
    func testFilterByName() {
        guard let realm = Realm.current else {
            XCTFail("realm could not be instantiated")
            return
        }

        let sub1 = Subscription.testInstance("sub1")
        let sub2 = Subscription.testInstance("sub2")

        realm.execute({ realm in
            realm.add(sub1, update: .all)
            realm.add(sub2, update: .all)
        })

        let objects = realm.objects(Subscription.self).filterBy(name: "sub1")

        XCTAssert(objects.count == 1)
        XCTAssert(objects.first == sub1)

        let objectsUppercase = realm.objects(Subscription.self).filterBy(name: "SUB1")

        XCTAssert(objectsUppercase.count == 1)
        XCTAssert(objectsUppercase.first == sub1)
    }

    func testLinkingObjectsFilterByName() {
        let realm = Realm.current

        let auth = Auth.testInstance()

        let sub1 = Subscription.testInstance("sub1")
        sub1.auth = auth

        let sub2 = Subscription.testInstance("sub2")
        sub2.auth = auth

        let sub3 = Subscription.testInstance("sub3")
        sub3.auth = auth
        sub3.open = false

        realm?.execute({ realm in
            realm.add(sub1, update: .all)
            realm.add(sub2, update: .all)
            realm.add(sub3, update: .all)
            realm.add(auth, update: .all)
        })

        guard let subscriptions = Subscription.all() else {
            fatalError("subscriptions must return values")
        }

        let objects = subscriptions.filterBy(name: "sub1")
        XCTAssertEqual(objects.count, 1)
        XCTAssertEqual(objects.first?.identifier, sub1.identifier)

        let objectsUppercase = subscriptions.filterBy(name: "SUB1")
        XCTAssertEqual(objectsUppercase.count, 1)
        XCTAssertEqual(objectsUppercase.first?.identifier, sub1.identifier)

        let objectsHidden = subscriptions.filterBy(name: "sub3")
        XCTAssertEqual(objectsHidden.count, 0)
    }

}

// MARK: URL generation

extension SubscriptionExtensionsSpec {

    func testURLGenerationChannelSubscription() {
        let authSettings = AuthSettings()
        authSettings.siteURL = "https://foo.bar"

        let auth = Auth()
        auth.settings = authSettings

        let subscription = Subscription()
        subscription.auth = auth
        subscription.name = "baz"
        subscription.type = .channel

        XCTAssertEqual(subscription.externalURL()?.absoluteString, "https://foo.bar/channel/baz")
    }

    func testURLGenerationGroupSubscription() {
        let authSettings = AuthSettings()
        authSettings.siteURL = "https://foo.bar"

        let auth = Auth()
        auth.settings = authSettings

        let subscription = Subscription()
        subscription.auth = auth
        subscription.name = "baz"
        subscription.type = .group

        XCTAssertEqual(subscription.externalURL()?.absoluteString, "https://foo.bar/group/baz")
    }

    func testURLGenerationDirectMessageSubscription() {
        let authSettings = AuthSettings()
        authSettings.siteURL = "https://foo.bar"

        let auth = Auth()
        auth.settings = authSettings

        let subscription = Subscription()
        subscription.auth = auth
        subscription.name = "baz"
        subscription.type = .directMessage

        XCTAssertEqual(subscription.externalURL()?.absoluteString, "https://foo.bar/direct/baz")
    }

    func testURLGenerationInvalidSiteURLSubscription() {
        let authSettings = AuthSettings()

        let auth = Auth()
        auth.settings = authSettings

        let subscription = Subscription()
        subscription.auth = auth
        subscription.name = "baz"

        XCTAssertNil(subscription.externalURL())
    }

    func testURLGenerationInvalidSettingsSubscription() {
        let auth = Auth()

        let subscription = Subscription()
        subscription.auth = auth
        subscription.name = "baz"

        XCTAssertNil(subscription.externalURL())
    }

    func testURLGenerationEmptyAuthSubscription() {
        let subscription = Subscription()
        subscription.name = "baz"

        XCTAssertNil(subscription.externalURL())
    }

    func testURLGenerationEmptyNameSubscription() {
        let authSettings = AuthSettings()
        authSettings.siteURL = "https://foo.bar"

        let auth = Auth()
        auth.settings = authSettings

        let subscription = Subscription()
        subscription.auth = auth

        XCTAssertNil(subscription.externalURL())
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
