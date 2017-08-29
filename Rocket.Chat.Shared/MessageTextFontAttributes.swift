//
//  MessageTextFontAttributes.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 01/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

enum MessageContainerStyle {
    case normal
    case sentBubble
    case receivedBubble
}

enum FontStyle {
    case normal
    case italic
    case bold
}

struct MessageTextFontAttributes {

    static let defaultFontSize = CGFloat(15)

    static let systemFontColor = UIColor.lightGray

    static func fontColor(for style: MessageContainerStyle) -> UIColor {
        switch style {
        case .normal:
            return UIColor.darkGray
        case .sentBubble:
            return UIColor.white
        case .receivedBubble:
            return UIColor.black
        }
    }

    static func font(for style: MessageContainerStyle, fontStyle: FontStyle = .normal) -> UIFont {
        switch style {
        case .normal:
            switch fontStyle {
            case .normal:
                return UIFont.systemFont(ofSize: defaultFontSize)
            case .italic:
                return UIFont.italicSystemFont(ofSize: defaultFontSize)
            case .bold:
                return UIFont.systemFont(ofSize: defaultFontSize)
            }
        case .receivedBubble, .sentBubble:
            switch fontStyle {
            case .normal:
                return UIFont.systemFont(ofSize: 16)
            case .italic:
                return UIFont.italicSystemFont(ofSize: 16)
            case .bold:
                return UIFont.systemFont(ofSize: 16)
            }
        }
    }

}
