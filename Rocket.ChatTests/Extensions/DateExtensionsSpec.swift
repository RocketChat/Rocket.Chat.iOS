//
//  DateExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import XCTest

@testable import Rocket_Chat

class DateExtension: XCTestCase {

    func testDateFromInterval() {
        let interval = 1468544344553.0
        let date = Date.dateFromInterval(interval)
        XCTAssert(date?.timeIntervalSince1970 == interval / 1000, "Date interval is divided by 1000")
    }

    func testDateFromServer() {
        let offset = Double(5000)

        ServerManager.shared.timestampOffset = offset

        let deviceDate = Date()
        let serverDate = Date.serverDate
        let difference = round(Double((deviceDate.timeIntervalSince1970 - serverDate.timeIntervalSince1970) * 1000))

        XCTAssert(difference == offset, "Offset from both are correct")
    }

}
