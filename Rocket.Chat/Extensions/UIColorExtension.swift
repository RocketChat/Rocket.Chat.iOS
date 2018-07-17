//
//  UIColorExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/4/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

enum SystemMessageColor {
    case warning
    case danger
    case good
    case unknown(String)

    init(rawValue: String) {
        switch rawValue {
        case SystemMessageColor.warning.rawValue: self = .warning
        case SystemMessageColor.danger.rawValue: self = .danger
        case SystemMessageColor.good.rawValue: self = .good
        default:
            self = .unknown(rawValue)
        }
    }

    var rawValue: String {
        return String(describing: self)
    }

    var color: UIColor {
        switch self {
        case .warning: return UIColor(rgb: 0xFCB316, alphaVal: 1)
        case .danger: return UIColor(rgb: 0xD30230, alphaVal: 1)
        case .good: return UIColor(rgb: 0x35AC19, alphaVal: 1)
        case .unknown(let string): return UIColor(hex: string)
        }
    }
}

extension UIColor {

    convenience init(rgb: Int, alphaVal: CGFloat) {
        self.init(
            red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgb & 0x0000FF) / 255.0,
            alpha: CGFloat(alphaVal)
        )
    }

    // MARK: Avatar Colors

    static var avatarColors: [UIColor] {
        return [
            0xF44336, 0xE91E63, 0x9C27B0, 0x673AB7, 0x3F51B5,
            0x2196F3, 0x03A9F4, 0x00BCD4, 0x009688, 0x4CAF50,
            0x8BC34A, 0xCDDC39, 0xFFC107, 0xFF9800, 0xFF5722,
            0x795548, 0x9E9E9E, 0x607D8B
        ].map { UIColor(rgb: $0, alphaVal: 1.0) }
    }

    static func forName(_ name: String) -> UIColor {
        return avatarColors[name.count % avatarColors.count]
    }

    // MARK: Color from strings

    static func normalizeColorFromString(string: String) -> UIColor {
        return SystemMessageColor(rawValue: string).color
    }

    // MARK: Status

    static func RCOnline() -> UIColor {
        return UIColor(rgb: 0x2DE0A5, alphaVal: 1)
    }

    static func RCAway() -> UIColor {
        return UIColor(rgb: 0xFFD21F, alphaVal: 1)
    }

    static func RCBusy() -> UIColor {
        return UIColor(rgb: 0xF5455C, alphaVal: 1)
    }

    static func RCInvisible() -> UIColor {
        return UIColor(rgb: 0xCBCED1, alphaVal: 1)
    }

    // MARK: Theme color

    static func RCNavigationBarColor() -> UIColor {
        return UIColor(rgb: 0xF8F8F8, alphaVal: 1)
    }

    static func RCBackgroundColor() -> UIColor {
        return UIColor(rgb: 0x2F343D, alphaVal: 1)
    }

    static func RCEditingAvatarColor() -> UIColor {
        return UIColor(rgb: 0xEAEAEA, alphaVal: 0.75)
    }

    static func RCTextFieldGray() -> UIColor {
        return UIColor(rgb: 10396328, alphaVal: 1)
    }

    static func RCTextFieldBorderGray() -> UIColor {
        return UIColor(rgb: 15199218, alphaVal: 1)
    }

    static func RCButtonBorderGray() -> UIColor {
        return UIColor(rgb: 14804456, alphaVal: 1)
    }

    static func RCDarkGray() -> UIColor {
        return UIColor(rgb: 0x333333, alphaVal: 1)
    }

    static func RCGray() -> UIColor {
        return UIColor(rgb: 0x9EA2A8, alphaVal: 1)
    }

    static func RCNavBarGray() -> UIColor {
        return UIColor(rgb: 3355443, alphaVal: 1)
    }

    static func RCLightGray() -> UIColor {
        return UIColor(rgb: 0xCBCED1, alphaVal: 1)
    }

    static func RCSeparatorGrey() -> UIColor {
        return UIColor(rgb: 0xC2C2C2, alphaVal: 0.5)
    }

    static func RCSkyBlue() -> UIColor {
        return UIColor(rgb: 1930485, alphaVal: 1)
    }

    static func RCDarkBlue() -> UIColor {
        return UIColor(rgb: 0x0a4469, alphaVal: 1)
    }

    static func RCLightBlue() -> UIColor {
        return UIColor(rgb: 0x9EA2A8, alphaVal: 1)
    }

    static func RCBlue() -> UIColor {
        return UIColor(rgb: 0x1D74F5, alphaVal: 1)
    }

    // MARK: Function color

    static func RCFavoriteMark() -> UIColor {
        return UIColor(rgb: 0xF8B62B, alphaVal: 1.0)
    }

    static func RCFavoriteUnmark() -> UIColor {
        return UIColor.lightGray
    }

    // MARK: Colors from Web Version

    static let primaryAction = UIColor(rgb: 0x13679A, alphaVal: 1)
    static let attention = UIColor(rgb: 0x9C27B0, alphaVal: 1)
    static let link = UIColor(rgb: 0x2578F1, alphaVal: 1)

    static var code: UIColor {
        return UIColor(rgb: 0x333333, alphaVal: 1.0)
    }

    static var codeBackground: UIColor {
        return UIColor(rgb: 0xF8F8F8, alphaVal: 1.0)
    }

    // MARK: Mention Color

    static func background(for mention: Mention) -> UIColor {
        if mention.username == AuthManager.currentUser()?.username {
            return .primaryAction
        }

        if mention.username == "all" || mention.username == "here" {
            return .attention
        }

        return .white
    }

    static func font(for mention: Mention) -> UIColor {
        if mention.username == AuthManager.currentUser()?.username {
            return .white
        }

        if mention.username == "all" || mention.username == "here" {
            return .white
        }

        return .link
    }
}

// MARK: UIKit default colors

extension UIColor {
    static var placeholderGray: UIColor {
        return UIColor(red: 199/255, green: 199/255, blue: 205/255, alpha: 1)
    }

    static var backgroundWhite: UIColor {
        return UIColor(red: 247/255, green: 247/255, blue: 247/255, alpha: 1)
    }
}

// MARK: Utils

extension UIColor {
    func isBrightColor() -> Bool {
        guard let components = cgColor.components else { return false }
        let brightness = ((components[0] * 299) + (components[1] * 587) + (components[2] * 114)) / 1000

        return brightness < 0.5 ? false : true
    }
}
