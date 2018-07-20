//
//  BaseViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol PopPushDelegate: class {
    func willBePushed(animated: Bool)
    func willBePopped(animated: Bool)
}

protocol NavigationBarTransparency: class {
    var isNavigationBarTransparent: Bool { get }
    func updateNavigationBarTransparency()
}

extension NavigationBarTransparency where Self: UIViewController {
    func updateNavigationBarTransparency() {
        if isNavigationBarTransparent {
            navigationController?.navigationBar.setTransparent()
        } else {
            navigationController?.navigationBar.setNonTransparent()
        }

        navigationController?.redrawNavigationBar()
    }
}

extension PopPushDelegate where Self: UIViewController & NavigationBarTransparency {
    func willBePushed(animated: Bool) {
        updateNavigationBarTransparency()
    }

    func willBePopped(animated: Bool) {
        if let controller = navigationController?.topViewController as? BaseViewController {
            controller.updateNavigationBarTransparency()
        } else {
            navigationController?.navigationBar.setNonTransparent()
            navigationController?.redrawNavigationBar()
        }
    }
}

class BaseViewController: UIViewController, PopPushDelegate, NavigationBarTransparency {
    var isNavigationBarTransparent: Bool {
        return false
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeManager.addObserver(self)

        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )

        popoverPresentationController?.backgroundColor = view.theme?.focusedBackground
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateNavigationBarTransparency()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        let screenName = String(describing: type(of: self))
        AnalyticsManager.log(event: .screenView(screenName: screenName))
    }

    override func applyTheme() {
        super.applyTheme()
        updateNavigationBarTransparency()
    }
}
