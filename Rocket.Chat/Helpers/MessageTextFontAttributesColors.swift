//
//  MessageTextFontAttributesColors.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 14/12/2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension MessageTextFontAttributes {
    static func defaultFontColor(for theme: Theme? = nil) -> UIColor {
        return theme?.bodyText ?? ThemeManager.theme.bodyText
    }
    
    static func systemFontColor(for theme: Theme? = ThemeManager.theme) -> UIColor {
        return theme?.auxiliaryText ?? ThemeManager.theme.auxiliaryText
    }
    
    static func failedFontColor(for theme: Theme? = ThemeManager.theme) -> UIColor {
        return theme?.auxiliaryText ?? ThemeManager.theme.auxiliaryText
    }
}
