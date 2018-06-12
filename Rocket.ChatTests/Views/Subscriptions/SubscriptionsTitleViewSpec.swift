//
//  SubscriptionsTitleViewSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 12/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class SubscriptionsTitleViewSpec: XCTestCase {

    func testInitializeFromNib() {
        XCTAssertNotNil(SubscriptionsTitleView.instantiateFromNib(), "instantiation from nib will work")
    }

    func testInitialStateFromWebSocket() {
        SocketManager.sharedInstance.state = .waitingForNetwork

        guard let instance = SubscriptionsTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.updateConnectionState()

        XCTAssertEqual(instance.state, .waitingForNetwork)
        XCTAssertFalse(instance.viewLoading.isHidden)
        XCTAssertTrue(instance.labelMessages.isHidden)
        XCTAssertFalse(instance.buttonServer.isHidden)
    }

    func testStateConnectedLabelsVisibility() {
        guard let instance = SubscriptionsTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.state = .connected
        XCTAssertTrue(instance.viewLoading.isHidden)
        XCTAssertFalse(instance.labelMessages.isHidden)
        XCTAssertFalse(instance.buttonServer.isHidden)
    }

    func testStateWaitingForNetworkLabelsVisibility() {
        guard let instance = SubscriptionsTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.state = .waitingForNetwork
        XCTAssertFalse(instance.viewLoading.isHidden)
        XCTAssertTrue(instance.labelMessages.isHidden)
        XCTAssertFalse(instance.buttonServer.isHidden)
    }

    func testStateConnectingLabelsVisibility() {
        guard let instance = SubscriptionsTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.state = .connecting
        XCTAssertFalse(instance.viewLoading.isHidden)
        XCTAssertTrue(instance.labelMessages.isHidden)
        XCTAssertFalse(instance.buttonServer.isHidden)
    }

}
