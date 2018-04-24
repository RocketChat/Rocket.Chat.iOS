//
//  BugTrackingCoordinatorSpec.swift
//  Rocket.ChatTests
//
//  Created by Rafael Kellermann Streit on 23/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import XCTest
import RealmSwift

@testable import Rocket_Chat

class BugTrackingCoordinatorSpec: XCTestCase {

    override func setUp() {
        super.setUp()
        BugTrackingCoordinator.toggleCrashReporting(disabled: false)
    }

    func testDefaultValue() {
        XCTAssertFalse(BugTrackingCoordinator.isCrashReportingDisabled)
    }

    func testValueChanged() {
        BugTrackingCoordinator.toggleCrashReporting(disabled: true)
        XCTAssertTrue(BugTrackingCoordinator.isCrashReportingDisabled)
    }

}
