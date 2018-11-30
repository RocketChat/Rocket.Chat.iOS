//
//  AuthNavigationController.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/25/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class AuthNavigationController: UINavigationController {

    override var shouldAutorotate: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return super.supportedInterfaceOrientations
        }

        return [.portrait]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let navBar = self.navigationBar
        navBar.isTranslucent = false
        navBar.tintColor = .RCBlue()
        navBar.barTintColor = .RCNavigationBarColor()
    }

    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        let viewControllers = super.popToRootViewController(animated: animated)
        setTransparentTheme()
        return viewControllers
    }

    override func popViewController(animated: Bool) -> UIViewController? {
        let poppedViewController = super.popViewController(animated: animated)

        if topViewController is ConnectServerViewController {
            setTransparentTheme()
        }

        return poppedViewController
    }

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {
        let pushedFromViewController = topViewController
        super.pushViewController(viewController, animated: animated)

        if viewController is LoginTableViewController || viewController is AuthTableViewController {
            setGrayTheme(
                forceRedraw: pushedFromViewController is ConnectServerViewController
            )
        }
    }

    func setTransparentTheme(forceRedraw: Bool = false) {
        let navBar = self.navigationBar
        navBar.barStyle = .default
        navBar.setBackgroundImage(UIImage(), for: .default)
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = UIColor.clear
        navBar.isTranslucent = true
        navBar.tintColor = .RCBlue()
        if forceRedraw { forceNavigationToRedraw() }
        setNeedsStatusBarAppearanceUpdate()
    }

    func setGrayTheme(forceRedraw: Bool = false) {
        let navBar = self.navigationBar
        navBar.barStyle = .black
        navBar.shadowImage = UIImage()
        navBar.backgroundColor = .RCNavBarGray()
        navBar.barTintColor = .RCNavBarGray()
        navBar.isTranslucent = false
        navBar.tintColor = .white
        navBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        if forceRedraw { forceNavigationToRedraw() }
        setNeedsStatusBarAppearanceUpdate()
    }

    func forceNavigationToRedraw() {
        isNavigationBarHidden = true
        isNavigationBarHidden = false
    }
}

// MARK: Disable Theming

extension AuthNavigationController {
    override func applyTheme() { }
}
