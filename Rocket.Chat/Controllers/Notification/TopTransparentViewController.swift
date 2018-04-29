//
//  TopTransparentViewController.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/30/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class TopTransparentViewController: UIViewController {
    override var preferredStatusBarStyle: UIStatusBarStyle {
        var topViewController = UIApplication.shared.delegate?.window??.rootViewController

        while let presentedViewController = topViewController?.presentedViewController,
            let visibleAfterTransitionViewController = presentedViewController.transitionCoordinator?.viewController(forKey: .to),
            visibleAfterTransitionViewController != topViewController {

                topViewController = topViewController?.presentedViewController
        }

        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
