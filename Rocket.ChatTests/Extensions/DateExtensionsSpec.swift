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

    func testDateFromString() {
        let localTimeZoneFormatter = DateFormatter()
        localTimeZoneFormatter.timeZone = TimeZone.current
        localTimeZoneFormatter.dateFormat = "Z"
        let localTimeOffset = localTimeZoneFormatter.string(from: Date())

        let dateString = "2017-04-26T20:10:32.866" + localTimeOffset

        guard let date = Date.dateFromString(dateString) else {
            XCTFail("Date is not nil")
            return
        }

        XCTAssertEqual(date.year, "2017", "Year is correct")
        XCTAssertEqual(date.month, "04", "Month is correct")
        XCTAssertEqual(date.day, "26", "Day is correct")
    }

    func testSameDayAs() {
        let date = Date()
        XCTAssertTrue(date.sameDayAs(date))

        let oneDay = 86400.0
        let date2 = date.addingTimeInterval(oneDay)

        XCTAssertFalse(date.sameDayAs(date2))
    }

}
