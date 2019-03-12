//
//  DateExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/11/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

extension Date {

    static var apiDateFormat: String = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"

    public static func dateFromInterval(_ interval: Double) -> Date? {
        return Date(timeIntervalSince1970: interval / 1000)
    }

    public static func dateFromString(_ string: String, format: String = "yyyy-MM-dd'T'HH:mm:ss.SSSZ") -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = format

        return dateFormatter.date(from: string)
    }

    public static func intervalFromDate(_ date: Date) -> Double {
        return date.timeIntervalSince1970 * 1000
    }

    var weekday: String {
        return self.formatted("EEE")
    }

    var day: String {
        return self.formatted("dd")
    }

    var month: String {
        return self.formatted("MM")
    }

    var monthString: String {
        return self.formatted("MMMM")
    }

    var year: String {
        return self.formatted("YYYY")
    }

    func formatted(_ format: String = "dd/MM/yyyy HH:mm:ss ZZZ", timeZone: TimeZone? = .current) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = timeZone
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        return dateFormatter.string(from: self)
    }

    var dayOfWeek: Int {
        let calendar = NSCalendar.current
        let comp: DateComponents = (calendar as NSCalendar).components(.weekday, from: self)
        return comp.weekday ?? -1
    }

    func sameDayAs(_ otherDate: Date) -> Bool {
        return Calendar.current.isDate(otherDate, inSameDayAs: self)
    }

}

// MARK: Extensions to sync timezone with server

extension Date {

    static var serverUnixTimestamp: TimeInterval {
        return Date().timeIntervalSince1970 * 1000 - ServerManager.shared.timestampOffset
    }

    static var serverDate: Date {
        return Date(timeIntervalSince1970: Date.serverUnixTimestamp / 1000)
    }

}
