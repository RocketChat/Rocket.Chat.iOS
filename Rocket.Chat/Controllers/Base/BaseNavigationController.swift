//
//  BaseNavigationController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

class BaseNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let navBar = self.navigationBar
        navBar.isTranslucent = false
        navBar.tintColor = .RCBlue()
        navBar.barTintColor = .RCNavigationBarColor()
    }

    func setTransparentTheme() {
        let navBar = self.navigationBar
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = UIColor.clear
        navBar.isTranslucent = true
        navBar.tintColor = .RCBlue()
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.RCBlue()]
    }

    func setWhiteTheme() {
        let navBar = self.navigationBar
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .white
        navBar.barTintColor = .white
        navBar.isTranslucent = false
        navBar.tintColor = .RCBlue()
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.RCBlue()]
    }

    func setGrayTheme() {
        let navBar = self.navigationBar
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .gray
        navBar.barTintColor = .gray
        navBar.isTranslucent = false
        navBar.tintColor = .white
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        setNeedsStatusBarAppearanceUpdate()
    }
}
