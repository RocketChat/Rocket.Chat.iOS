//
//  MessageTextFontAttributes.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 01/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct MessageTextFontAttributes {

    static let defaultFontSize = CGFloat(16)

    static func defaultFontColor(for theme: Theme? = nil) -> UIColor {
        return theme?.controlText ?? ThemeManager.theme.controlText
    }

    static func systemFontColor(for theme: Theme? = ThemeManager.theme) -> UIColor {
        return theme?.auxiliaryText ?? ThemeManager.theme.auxiliaryText
    }

    static func failedFontColor(for theme: Theme? = ThemeManager.theme) -> UIColor {
        return theme?.auxiliaryText ?? ThemeManager.theme.auxiliaryText
    }

    static var defaultFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let sizeDescriptor = defaultFontDescriptor.withSize(defaultFontSize)
        let font = UIFont(descriptor: sizeDescriptor, size: 0)

        if #available(iOS 11.0, *) {
            return UIFontMetrics.default.scaledFont(for: font)
        } else {
            return font
        }
    }

    static var italicFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let sizeDescriptor = defaultFontDescriptor.withSize(defaultFontSize).withSymbolicTraits(.traitItalic)

        let font: UIFont

        if let sizeDescriptor = sizeDescriptor {
            font = UIFont(descriptor: sizeDescriptor, size: 0)
        } else {
            font = UIFont.italicSystemFont(ofSize: defaultFontSize)
        }

        if #available(iOS 11.0, *) {
            return UIFontMetrics.default.scaledFont(for: font)
        } else {
            return font
        }
    }

    static var boldFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let sizeDescriptor = defaultFontDescriptor.withSize(defaultFontSize).withSymbolicTraits(.traitBold)

        let font: UIFont

        if let sizeDescriptor = sizeDescriptor {
            font = UIFont(descriptor: sizeDescriptor, size: 0)
        } else {
            font = UIFont.italicSystemFont(ofSize: defaultFontSize)
        }

        if #available(iOS 11.0, *) {
            return UIFontMetrics.default.scaledFont(for: font)
        } else {
            return font
        }
    }

}
