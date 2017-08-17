//
//  DoubleExtensions.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 8/17/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension Double {
    var radius: CGFloat {
        return CGFloat(self / 180 * .pi)
    }
}
