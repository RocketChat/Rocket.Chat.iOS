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
    }
    
    func setTransparentTheme() {
        let navBar = self.navigationBar
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = UIColor.clear
        navBar.isTranslucent = true
        navBar.tintColor = UIColor.white
        navBar.titleTextAttributes = [NSForegroundColorAttributeName : UIColor.white]
    }
    
}
