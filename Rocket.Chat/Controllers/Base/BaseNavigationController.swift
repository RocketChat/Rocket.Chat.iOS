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

    override var shouldAutorotate: Bool {
        guard let topViewController = topViewController else { return true }
        return !(topViewController is WelcomeViewController)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let navBar = self.navigationBar
        navBar.isTranslucent = false
        navBar.tintColor = .RCBlue()
        navBar.barTintColor = .RCNavigationBarColor()
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let poppedViewController = super.popViewController(animated: animated)

        if (poppedViewController as? AuthTableViewController) != nil || (poppedViewController as? LoginTableViewController) != nil {
            setTransparentTheme()
        }

        return poppedViewController
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        super.pushViewController(viewController, animated: animated)

        if viewController is LoginTableViewController {
            setGrayTheme()
        }
    }

    func setTransparentTheme() {
        UIApplication.shared.statusBarStyle = .default
        let navBar = self.navigationBar
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = UIColor.clear
        navBar.isTranslucent = true
        navBar.tintColor = .RCBlue()
    }

    func setGrayTheme() {
        UIApplication.shared.statusBarStyle = .lightContent
        let navBar = self.navigationBar
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .RCNavBarGray()
        navBar.barTintColor = .RCNavBarGray()
        navBar.isTranslucent = false
        navBar.tintColor = .white
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        isNavigationBarHidden = true
        isNavigationBarHidden = false
    }
}
