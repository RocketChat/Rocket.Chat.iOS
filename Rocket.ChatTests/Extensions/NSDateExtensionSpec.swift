//
//  NSDateExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class NSDateExtension: XCTestCase {

    func testDateFromInterval() {
        let interval = 1468544344553.0
        let date = Date.dateFromInterval(interval)
        XCTAssert(date?.timeIntervalSince1970 == interval / 1000, "Date interval is divided by 1000")
    }

}
