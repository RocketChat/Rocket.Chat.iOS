//
//  SubscriptionsSortingViewModelSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 08/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

extension SubscriptionsSortingManager {

    internal static func resetValues() {
        let defaults = UserDefaults.group
        let sorting: [SubscriptionsSortingOption] = [.activity, .alphabetically]
        let grouping: [SubscriptionsGroupingOption] = [.unread, .favorites, .type]
        sorting.forEach({ defaults.removeObject(forKey: key(for: $0.rawValue)) })
        grouping.forEach({ defaults.removeObject(forKey: key(for: $0.rawValue)) })
    }

}

class SubscriptionsSortingViewModelSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        SubscriptionsSortingManager.resetValues()
    }

    override func tearDown() {
        super.tearDown()
        SubscriptionsSortingManager.resetValues()
    }

    func testInitialState() {
        let instance = SubscriptionsSortingViewModel()
        let sortingOptions = instance.sortingOptions
        let groupingOptions = instance.groupingOptions

        XCTAssertEqual(instance.numberOfSections, 2)
        XCTAssertEqual(instance.numberOfRows(section: 0), sortingOptions.count)
        XCTAssertEqual(instance.numberOfRows(section: 1), groupingOptions.count)
        XCTAssertEqual(instance.viewHeight, CGFloat(groupingOptions.count + sortingOptions.count) * SubscriptionSortingCell.cellHeight + instance.listSeparatorHeight)
        XCTAssertTrue(instance.isSelected(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertFalse(instance.isSelected(indexPath: IndexPath(row: 1, section: 0)))
        XCTAssertFalse(instance.isSelected(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertFalse(instance.isSelected(indexPath: IndexPath(row: 1, section: 1)))
        XCTAssertFalse(instance.isSelected(indexPath: IndexPath(row: 2, section: 1)))
        XCTAssertTrue(instance.initialTableViewPosition < 0)
    }

    func testViewStateChangeSorting() {
        let instance = SubscriptionsSortingViewModel()
        instance.select(indexPath: IndexPath(row: 1, section: 0))

        // First row got deselected & second got selected
        XCTAssertFalse(instance.isSelected(indexPath: IndexPath(row: 0, section: 0)))
        XCTAssertTrue(instance.isSelected(indexPath: IndexPath(row: 1, section: 0)))
    }

    func testViewStateChooseOneGrouping() {
        let instance = SubscriptionsSortingViewModel()
        instance.select(indexPath: IndexPath(row: 0, section: 1))

        // Only first row got selected
        XCTAssertTrue(instance.isSelected(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertFalse(instance.isSelected(indexPath: IndexPath(row: 1, section: 1)))
        XCTAssertFalse(instance.isSelected(indexPath: IndexPath(row: 2, section: 1)))
    }

    func testViewStateChooseTwoGrouping() {
        let instance = SubscriptionsSortingViewModel()
        instance.select(indexPath: IndexPath(row: 0, section: 1))
        instance.select(indexPath: IndexPath(row: 2, section: 1))

        // Two rows got selected
        XCTAssertTrue(instance.isSelected(indexPath: IndexPath(row: 0, section: 1)))
        XCTAssertFalse(instance.isSelected(indexPath: IndexPath(row: 1, section: 1)))
        XCTAssertTrue(instance.isSelected(indexPath: IndexPath(row: 2, section: 1)))
    }

    func testViewStateToggleGrouping() {
        let instance = SubscriptionsSortingViewModel()

        // Select Option
        instance.select(indexPath: IndexPath(row: 0, section: 1))
        XCTAssertTrue(instance.isSelected(indexPath: IndexPath(row: 0, section: 1)))

        // Deselect Option
        instance.select(indexPath: IndexPath(row: 0, section: 1))
        XCTAssertFalse(instance.isSelected(indexPath: IndexPath(row: 0, section: 1)))
    }

}
