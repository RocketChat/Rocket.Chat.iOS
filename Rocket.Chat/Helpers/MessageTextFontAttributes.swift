//
//  MessageTextFontAttributes.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 01/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct MessageTextFontAttributes {

    static let defaultFontSize = CGFloat(15)

    // TODO: Probably should not be changed here
    static var defaultFontColor: UIColor {
        return ThemeManager.theme.bodyText
    } //UIColor.darkGray
    static var systemFontColor: UIColor {
        return ThemeManager.theme.auxiliaryText
    } //UIColor.lightGray
    static var failedFontColor: UIColor {
        return ThemeManager.theme.auxiliaryBackground
    } //UIColor.lightGray

    static let defaultFont = UIFont.systemFont(ofSize: defaultFontSize)
    static let italicFont = UIFont.italicSystemFont(ofSize: defaultFontSize)
    static let boldFont = UIFont.boldSystemFont(ofSize: defaultFontSize)

}
