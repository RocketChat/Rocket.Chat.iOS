//
//  BaseNavigationBar.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

protocol BaseNavigationBarThemeSource: class {
    var navigationBarTheme: Theme? { get }
}

class BaseNavigationBar: UINavigationBar {
    weak var themeSource: BaseNavigationBarThemeSource?
    override var theme: Theme? {
        return themeSource?.navigationBarTheme
    }
}
