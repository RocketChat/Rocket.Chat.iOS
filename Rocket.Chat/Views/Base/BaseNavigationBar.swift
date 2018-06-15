//
//  BaseNavigationBar.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

protocol BaseNavigationBarThemeSource {
    var navgiationBarTheme: Theme? { get }
}

class BaseNavigationBar: UINavigationBar {
    var themeSource: BaseNavigationBarThemeSource?
    override var theme: Theme? {
        return themeSource?.navgiationBarTheme
    }
}
