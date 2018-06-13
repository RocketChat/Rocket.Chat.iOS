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

        self.navigationItem.backBarButtonItem = UIBarButtonItem(
            title: "",
            style: .plain,
            target: nil,
            action: nil
        )
    }
}
