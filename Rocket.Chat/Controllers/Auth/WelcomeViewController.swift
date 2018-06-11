//
//  WelcomeViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class WelcomeViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        if let nav = navigationController as? BaseNavigationController {
            nav.setTransparentTheme()
        }
    }

}
