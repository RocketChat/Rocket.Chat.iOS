//
//  AnalyticsCoordinatorSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 23/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class AnalyticsCoordinatorSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        AnalyticsCoordinator.toggleCrashReporting(disabled: false)
    }

    func testDefaultValue() {
        XCTAssertFalse(AnalyticsCoordinator.isUsageDataLoggingDisabled)
    }

    func testValueChanged() {
        AnalyticsCoordinator.toggleCrashReporting(disabled: true)
        XCTAssertTrue(AnalyticsCoordinator.isUsageDataLoggingDisabled)
    }

}
