//
//  TopTransparentViewController.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class TopTransparentViewController: UIViewController {
    func willStartDisplayingContent() {
        (UIApplication.shared.delegate as? AppDelegate)?.notificationWindow?.isHidden = false
    }

    func didEndDisplayingContent() {
        (UIApplication.shared.delegate as? AppDelegate)?.notificationWindow?.isHidden = true
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIApplication.shared.statusBarStyle
    }
}
