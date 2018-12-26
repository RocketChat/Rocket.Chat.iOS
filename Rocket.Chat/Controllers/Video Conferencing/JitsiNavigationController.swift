//
//  JitsiNavigationController.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 26/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class JitsiNavigationController: BaseNavigationController {

    override var prefersStatusBarHidden: Bool {
        return false
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        isNavigationBarHidden = true
    }

}
