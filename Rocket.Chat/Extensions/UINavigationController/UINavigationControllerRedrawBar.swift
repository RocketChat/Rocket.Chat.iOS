//
//  UINavigationControllerRedrawBar.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 7/4/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UINavigationController {
    func redrawNavigationBar() {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isNavigationBarHidden = false
    }
}
