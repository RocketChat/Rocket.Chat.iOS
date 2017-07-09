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

    static let defaultFont = UIFont.systemFont(ofSize: defaultFontSize)
    static let italicFont = UIFont.italicSystemFont(ofSize: defaultFontSize)
    static let boldFont = UIFont.systemFont(ofSize: defaultFontSize)

}
