//
//  SubscriptionSortingManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 08/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class SubscriptionSortingManagerSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        SubscriptionsSortingManager.resetValues()
    }

    override func tearDown() {
        super.tearDown()
        SubscriptionsSortingManager.resetValues()
    }

    func testGeneratedKey() {
        XCTAssertEqual(SubscriptionsSortingManager.key(for: SubscriptionsGroupingOption.type.rawValue), "kSortingKey-type")
    }

    func testInitialState() {
        XCTAssertEqual(SubscriptionsSortingManager.selectedSortingOption, .activity)
        XCTAssertEqual(SubscriptionsSortingManager.selectedGroupingOptions.count, 0)
    }

    func testSortingOptionSelected() {
        SubscriptionsSortingManager.select(option: .alphabetically)
        XCTAssertEqual(SubscriptionsSortingManager.selectedSortingOption, .alphabetically)
    }

    func testToggleSelectGroupingValue() {
        SubscriptionsSortingManager.toggle(option: SubscriptionsGroupingOption.type.rawValue)
        XCTAssertEqual(SubscriptionsSortingManager.selectedGroupingOptions.count, 1)
        XCTAssertEqual(SubscriptionsSortingManager.selectedGroupingOptions.first, .type)
    }

    func testToggleDeselectGroupingValue() {
        SubscriptionsSortingManager.toggle(option: SubscriptionsGroupingOption.type.rawValue)
        XCTAssertEqual(SubscriptionsSortingManager.selectedGroupingOptions.count, 1)
        XCTAssertEqual(SubscriptionsSortingManager.selectedGroupingOptions.first, .type)

        SubscriptionsSortingManager.toggle(option: SubscriptionsGroupingOption.type.rawValue)
        XCTAssertEqual(SubscriptionsSortingManager.selectedGroupingOptions.count, 0)
    }

    func testToggleSelectGroupingMultipleValues() {
        SubscriptionsSortingManager.toggle(option: SubscriptionsGroupingOption.type.rawValue)
        SubscriptionsSortingManager.toggle(option: SubscriptionsGroupingOption.favorites.rawValue)
        SubscriptionsSortingManager.toggle(option: SubscriptionsGroupingOption.unread.rawValue)
        XCTAssertEqual(SubscriptionsSortingManager.selectedGroupingOptions.count, 3)
        XCTAssertTrue(SubscriptionsSortingManager.selectedGroupingOptions.contains(.type))

        SubscriptionsSortingManager.toggle(option: SubscriptionsGroupingOption.type.rawValue)
        XCTAssertEqual(SubscriptionsSortingManager.selectedGroupingOptions.count, 2)
        XCTAssertFalse(SubscriptionsSortingManager.selectedGroupingOptions.contains(.type))
    }

}
