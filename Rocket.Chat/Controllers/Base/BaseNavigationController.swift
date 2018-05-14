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
        navBar.tintColor = .RCDarkGray()
        navBar.barTintColor = UIColor(red: 0.969, green: 0.969, blue: 0.969, alpha: 1.0)
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
}
