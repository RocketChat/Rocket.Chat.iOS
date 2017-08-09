//
//  IntExtensions.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 8/9/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension Int {
    var times: CountableClosedRange<Int> {
        return 1...self
    }
}
