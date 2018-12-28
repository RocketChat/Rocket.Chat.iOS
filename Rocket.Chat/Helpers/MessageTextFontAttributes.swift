//
//  MessageTextFontAttributes.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 01/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct MessageTextFontAttributes {
    static var defaultFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let font = UIFont(descriptor: defaultFontDescriptor, size: 0)

        if #available(iOS 11.0, *) {
            return UIFontMetrics.default.scaledFont(for: font)
        } else {
            return font
        }
    }

    static var italicFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let fontDescriptor = defaultFontDescriptor.withSymbolicTraits(.traitItalic)

        let font: UIFont

        if let fontDescriptor = fontDescriptor {
            font = UIFont(descriptor: fontDescriptor, size: 0)
        } else {
            font = UIFont.italicSystemFont(ofSize: 16)
        }

        if #available(iOS 11.0, *) {
            return UIFontMetrics.default.scaledFont(for: font)
        } else {
            return font
        }
    }

    static var boldFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let fontDescriptor = defaultFontDescriptor.withSymbolicTraits(.traitBold)

        let font: UIFont

        if let fontDescriptor = fontDescriptor {
            font = UIFont(descriptor: fontDescriptor, size: 0)
        } else {
            font = UIFont.italicSystemFont(ofSize: 16)
        }

        if #available(iOS 11.0, *) {
            return UIFontMetrics.default.scaledFont(for: font)
        } else {
            return font
        }
    }

    static var monoSpacedFont: UIFont {
        let defaultFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: .body)
        let fontDescriptor = defaultFontDescriptor.withSymbolicTraits(.traitMonoSpace)?.withSymbolicTraits(.traitBold)

        let font: UIFont

        if let fontDescriptor = fontDescriptor {
            font = UIFont(descriptor: fontDescriptor, size: 0)
        } else {
            font = UIFont.italicSystemFont(ofSize: 16)
        }

        if #available(iOS 11.0, *) {
            return UIFontMetrics.default.scaledFont(for: font)
        } else {
            return font
        }
    }

}
