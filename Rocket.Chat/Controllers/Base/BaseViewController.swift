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

    func willBePushed(animated: Bool) {
        if isNavigationBarTransparent {
            navigationController?.navigationBar.setTransparent()
        } else {
            navigationController?.navigationBar.setNonTransparent()
        }

        navigationController?.redrawNavigationBar()
    }

    func willBePopped(animated: Bool) {
        if (navigationController?.topViewController as? BaseViewController)?.isNavigationBarTransparent == true {
            navigationController?.navigationBar.setTransparent()
        } else {
            navigationController?.navigationBar.setNonTransparent()
        }

        navigationController?.redrawNavigationBar()
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
}
