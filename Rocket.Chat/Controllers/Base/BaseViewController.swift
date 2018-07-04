//
//  BaseViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    var isNavigationBarTransparent: Bool {
        return false
    }

    func updateNavigationBarTransparency() {
        if isNavigationBarTransparent {
            navigationController?.navigationBar.setTransparent()
        } else {
            navigationController?.navigationBar.setNonTransparent()
        }

        navigationController?.redrawNavigationBar()
    }

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

    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeManager.addObserver(self)

        navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
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
