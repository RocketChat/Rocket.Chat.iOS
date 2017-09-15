//
//  UserReviewManagerSpec.swift
//  Rocket.ChatTests
//
//  Created by Augusto Falcão on 9/15/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import XCTest
@testable import Rocket_Chat

class UserReviewManagerSpec: XCTestCase {
    func testCalculateNextDateForReview() {
        let manager = UserReviewManager()
        let week: TimeInterval = 604800
        let nextWeek = Date().addingTimeInterval(week)

        XCTAssert(manager.calculateNextDateForReview().timeIntervalSince(nextWeek) < 0.1, "calculateNextDateForReview returns the value from next week in seconds")
    }

    func testSharedInstanceNotNil() {
        let manager = UserReviewManager.shared
        XCTAssertNotNil(manager, "shared instance isn't nil")
    }

    func testRequestReviewSuccess() {
        let week: TimeInterval = 604800
        let manager = UserReviewManager()
        manager.nextDateForReview = Date(timeIntervalSince1970: week)
        XCTAssert(manager.requestReview(), "manager requests user for review")
    }

    func testRequestReviewFailure() {
        let week: TimeInterval = 604800
        let manager = UserReviewManager()
        manager.nextDateForReview = Date(timeIntervalSinceNow: week)
        XCTAssertFalse(manager.requestReview(), "manager fails to request user for review")
    }
}
