//
//  ChatTitleViewSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 12/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class ChatTitleViewSpec: XCTestCase {

    func testInitializeFromNib() {
        XCTAssertNotNil(ChatTitleView.instantiateFromNib(), "instantiation from nib will work")
    }

    func testInitialStateFromWebSocket() {
        SocketManager.sharedInstance.state = .waitingForNetwork

        guard let instance = ChatTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.updateConnectionState()

        XCTAssertEqual(instance.state, .waitingForNetwork)
        XCTAssertFalse(instance.viewLoading.isHidden)
        XCTAssertTrue(instance.buttonTitle.isHidden)
    }

    func testStateConnectedLabelsVisibility() {
        guard let instance = ChatTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.state = .connected
        XCTAssertTrue(instance.viewLoading.isHidden)
        XCTAssertFalse(instance.buttonTitle.isHidden)
    }

    func testStateWaitingForNetworkLabelsVisibility() {
        guard let instance = ChatTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.state = .waitingForNetwork
        XCTAssertFalse(instance.viewLoading.isHidden)
        XCTAssertTrue(instance.buttonTitle.isHidden)
    }

    func testStateConnectingLabelsVisibility() {
        guard let instance = ChatTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.state = .connecting
        XCTAssertFalse(instance.viewLoading.isHidden)
        XCTAssertTrue(instance.buttonTitle.isHidden)
    }

}
