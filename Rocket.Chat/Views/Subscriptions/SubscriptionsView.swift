//
//  SubscriptionsView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/29/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionsView: UIView {
    @IBOutlet weak var subscriptionsTableView: UITableView!
}

extension SubscriptionsView {
    override var theme: Theme? {
        return nil
    }

    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        subscriptionsTableView.backgroundColor = .RCBlue()
    }
}
