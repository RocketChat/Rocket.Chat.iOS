//
//  ChatTitleViewSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 11/23/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class ChatTitleViewSpec: XCTestCase {

    func testInitializeFromNib() {
        XCTAssertNotNil(ChatTitleView.instantiateFromNib(), "instantiation from nib will work")
    }

    func testUpdateSubscriptionNil() {
        let instance = ChatTitleView.instantiateFromNib()
        instance?.subscription = nil
        XCTAssertNil(instance?.subscription, "subscription will be nil")
    }

    func testUpdateSubscriptionValid() {
        let instance = ChatTitleView.instantiateFromNib()
        let subscription = Subscription.testInstance()
        instance?.subscription = subscription

        XCTAssertNotNil(instance?.subscription, "subscription won't be nil")
    }

    func testTitleLabelText() {
        let instance = ChatTitleView.instantiateFromNib()
        let subscription = Subscription.testInstance()
        instance?.subscription = subscription
        XCTAssertEqual(instance?.labelTitle.text, subscription.name, "title will be exactly the same as subsc name")
    }

}
