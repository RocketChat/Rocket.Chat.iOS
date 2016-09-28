//
//  NSDateExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/11/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

extension Date {
    
    public static func dateFromInterval(_ interval: Double) -> Date? {
        return Date(timeIntervalSince1970: interval / 1000)
    }

    public static func intervalFromDate(_ date: Date) -> Double {
        return date.timeIntervalSince1970 * 1000
    }
    
}
