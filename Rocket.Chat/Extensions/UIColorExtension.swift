//
//  UIColorExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/4/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIColor {

    convenience init(rgb: UInt, alphaVal: CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alphaVal)
        )
    }

    // Status

    static func RCOnline() -> UIColor {
        return UIColor(rgb: 0x35AC19, alphaVal: 1)
    }

    static func RCAway() -> UIColor {
        return UIColor(rgb: 0xFCB316, alphaVal: 1)
    }

    static func RCBusy() -> UIColor {
        return UIColor(rgb: 0xD30230, alphaVal: 1)
    }

    static func RCInvisible() -> UIColor {
        return UIColor(rgb: 0x9AB1BF, alphaVal: 1)
    }

    // Theme color

    static func RCDarkBlue() -> UIColor {
        return UIColor(rgb: 0x0a4469, alphaVal: 1)
    }

    static func RCLightBlue() -> UIColor {
        return UIColor(rgb: 0x9ab1bf, alphaVal: 1)
    }

    static func RCBlue() -> UIColor {
        return UIColor(rgb: 0x0b4c74, alphaVal: 1)
    }

}
