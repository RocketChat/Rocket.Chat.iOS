//
//  BaseViewController.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/6/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

// swiftlint:disable private_over_fileprivate
fileprivate func baseViewDidLoad(controller: UIViewController) {
    ThemeManager.addObserver(controller)

    controller.navigationItem.backBarButtonItem = UIBarButtonItem(
        title: "",
        style: .plain,
        target: nil,
        action: nil
    )
}

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        baseViewDidLoad(controller: self)
    }
}

class BaseTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        baseViewDidLoad(controller: self)
    }
}
