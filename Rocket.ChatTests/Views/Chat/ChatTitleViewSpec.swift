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
        XCTAssertTrue(instance.isTitleHidden)
    }

    func testStateConnectedLabelsVisibility() {
        guard let instance = ChatTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.state = .connected
        XCTAssertTrue(instance.viewLoading.isHidden)
        XCTAssertFalse(instance.isTitleHidden)
    }

    func testStateWaitingForNetworkLabelsVisibility() {
        guard let instance = ChatTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.state = .waitingForNetwork
        XCTAssertFalse(instance.viewLoading.isHidden)
        XCTAssertTrue(instance.isTitleHidden)
    }

    func testStateConnectingLabelsVisibility() {
        guard let instance = ChatTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.state = .connecting
        XCTAssertFalse(instance.viewLoading.isHidden)
        XCTAssertTrue(instance.isTitleHidden)
    }

    func testIsTitleHiddenTrue() {
        guard let instance = ChatTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.isTitleHidden = true
        XCTAssertTrue(instance.titleScrollView.isHidden, "titleScrollView should be hidden")
        XCTAssertTrue(instance.titleLabel.isHidden, "titleLabel should be hidden")
        XCTAssertTrue(instance.titleImage.isHidden, "titleImage should be hidden")
        XCTAssertTrue(instance.showInfoImage.isHidden, "showInfoImage should be hidden")
    }

    func testIsTitleHiddenFalse() {
        guard let instance = ChatTitleView.instantiateFromNib() else {
            return XCTFail("instantion from nib should've worked")
        }

        instance.isTitleHidden = false
        XCTAssertFalse(instance.titleLabel.isHidden, "titleLabel should not be hidden")
        XCTAssertFalse(instance.titleImage.isHidden, "titleImage should not be hidden")
        XCTAssertFalse(instance.showInfoImage.isHidden, "showInfoImage should not be hidden")
    }
}
