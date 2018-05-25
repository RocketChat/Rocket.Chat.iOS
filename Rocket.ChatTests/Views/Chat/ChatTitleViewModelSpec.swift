//
//  ChatTitleViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 11/23/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ChatTitleViewModelSpec: XCTestCase {

    func testInitialState() {
        let model = ChatTitleViewModel()

        XCTAssertNil(model.subscription, "subscription is nil")
        XCTAssertEqual(model.iconColor, .RCGray(), "default color is gray")
        XCTAssertEqual(model.imageName, "Channel Small", "default icon is hashtag")
        XCTAssertEqual(model.title, "", "title is empty string")
    }

    func testClearState() {
        let model = ChatTitleViewModel()
        model.subscription = nil
        model.user = nil

        XCTAssertNil(model.subscription, "subscription is nil")
        XCTAssertEqual(model.iconColor, .RCGray(), "default color is gray")
        XCTAssertEqual(model.imageName, "Channel Small", "default icon is hashtag")
        XCTAssertEqual(model.title, "", "title is empty string")
    }

    func testSubscriptionChannel() {
        let model = ChatTitleViewModel()
        let subscription = Subscription.testInstance()
        model.subscription = subscription

        XCTAssertNotNil(model.subscription, "subscription isn't nil")
        XCTAssertNil(model.user, "user is nil")
        XCTAssertEqual(model.iconColor, .RCGray(), "channel color is gray")
        XCTAssertEqual(model.imageName, "Channel Small", "channel icon is hashtag")
        XCTAssertEqual(model.title, subscription.displayName(), "title is subscription displayName()")
    }

    func testSubscriptionGroup() {
        let model = ChatTitleViewModel()
        let subscription = Subscription.testInstance()
        subscription.privateType = "p"
        model.subscription = subscription

        XCTAssertNotNil(model.subscription, "subscription isn't nil")
        XCTAssertNil(model.user, "user is nil")
        XCTAssertEqual(model.iconColor, .RCGray(), "group color is gray")
        XCTAssertEqual(model.imageName, "Group Small", "group icon is lock")
        XCTAssertEqual(model.title, subscription.displayName(), "title is subscription displayName()")
    }

    func testSubscriptionUserOffline() {
        let model = ChatTitleViewModel()
        let subscription = Subscription.testInstance()
        subscription.privateType = "d"
        model.subscription = subscription

        let user = User.testInstance()
        user.status = .offline
        model.user = user

        XCTAssertNotNil(model.subscription, "subscription isn't nil")
        XCTAssertNotNil(model.user, "user isn't nil")
        XCTAssertEqual(model.iconColor, .RCGray(), "color is gray")
        XCTAssertEqual(model.imageName, "DM Small", "icon is mention")
        XCTAssertEqual(model.title, subscription.displayName(), "title is subscription displayName()")
    }

    func testSubscriptionUserOnline() {
        let model = ChatTitleViewModel()
        let subscription = Subscription.testInstance()
        subscription.privateType = "d"
        model.subscription = subscription

        let user = User.testInstance()
        user.status = .online
        model.user = user

        XCTAssertNotNil(model.subscription, "subscription isn't nil")
        XCTAssertNotNil(model.user, "user isn't nil")
        XCTAssertEqual(model.iconColor, .RCOnline(), "color is online")
        XCTAssertEqual(model.imageName, "DM Small", "icon is mention")
        XCTAssertEqual(model.title, subscription.displayName(), "title is subscription displayName()")
    }

    func testSubscriptionUserAway() {
        let model = ChatTitleViewModel()
        let subscription = Subscription.testInstance()
        subscription.privateType = "d"
        model.subscription = subscription

        let user = User.testInstance()
        user.status = .away
        model.user = user

        XCTAssertNotNil(model.subscription, "subscription isn't nil")
        XCTAssertNotNil(model.user, "user isn't nil")
        XCTAssertEqual(model.iconColor, .RCAway(), "color is online")
        XCTAssertEqual(model.imageName, "DM Small", "icon is mention")
        XCTAssertEqual(model.title, subscription.displayName(), "title is subscription displayName()")
    }

    func testSubscriptionUserBusy() {
        let model = ChatTitleViewModel()
        let subscription = Subscription.testInstance()
        subscription.privateType = "d"
        model.subscription = subscription

        let user = User.testInstance()
        user.status = .busy
        model.user = user

        XCTAssertNotNil(model.subscription, "subscription isn't nil")
        XCTAssertNotNil(model.user, "user isn't nil")
        XCTAssertEqual(model.iconColor, .RCBusy(), "color is busy")
        XCTAssertEqual(model.imageName, "DM Small", "icon is mention")
        XCTAssertEqual(model.title, subscription.displayName(), "title is subscription displayName()")
    }

    func testSubscriptionUserNilAfterSubscriptionUpdate() {
        let model = ChatTitleViewModel()
        let subscription = Subscription.testInstance()
        subscription.privateType = "c"
        model.subscription = subscription

        let user = User.testInstance()
        user.status = .busy
        model.user = user

        model.subscription = subscription

        XCTAssertNotNil(model.subscription, "subscription is nil")
        XCTAssertEqual(model.iconColor, .RCGray(), "default color is gray")
        XCTAssertEqual(model.imageName, "Channel Small", "default icon is hashtag")
        XCTAssertEqual(model.title, subscription.displayName(), "title is subscription displayName()")
    }

}
