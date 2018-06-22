//
//  NotThemeableViews.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/29/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class NotThemeableView: UIView {
    override var theme: Theme? { return nil }
}

class NotThemeableTableView: UITableView {
    override var theme: Theme? { return nil }
}

class NotThemeableNavigationBar: UINavigationBar {
    override var theme: Theme? { return nil }
}

class NotThemeableLabel: UILabel {
    override var theme: Theme? { return nil }
}
