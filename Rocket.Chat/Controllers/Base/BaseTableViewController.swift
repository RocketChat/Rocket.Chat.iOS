//
//  BaseTableViewController.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 13/06/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class BaseTableViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()

        ThemeManager.addObserver(self)

        self.navigationItem.backBarButtonItem = UIBarButtonItem(
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
