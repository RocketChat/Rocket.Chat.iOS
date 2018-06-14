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

    override init(rootViewController: UIViewController) {
        super.init(navigationBarClass: BaseNavigationBar.self, toolbarClass: nil)
        self.setViewControllers([rootViewController], animated: false)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        let navBar = self.navigationBar
        navBar.isTranslucent = false
        (navBar as? BaseNavigationBar)?.themeSource = self
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
        navBar.applyTheme()
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
        navBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        if forceRedraw { forceNavigationToRedraw() }
        navBar.applyTheme()
        setNeedsStatusBarAppearanceUpdate()
    }

    func forceNavigationToRedraw() {
        isNavigationBarHidden = true
        isNavigationBarHidden = false
    }
}

extension BaseNavigationController: BaseNavigationBarThemeSource {
    var navgiationBarTheme: Theme? {
        return topViewController?.view.theme
    }
}
