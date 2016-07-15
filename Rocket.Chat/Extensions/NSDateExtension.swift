//
//  NSDateExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/11/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

extension NSDate {
    
    public static func dateFromInterval(interval: Double) -> NSDate? {
        return NSDate(timeIntervalSince1970: interval / 1000)
    }
    
}