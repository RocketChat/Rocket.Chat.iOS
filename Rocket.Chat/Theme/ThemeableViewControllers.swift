//
//  ThemeableViewControllers.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 5/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIViewController: Themeable {
    func applyTheme() {
        view.applyTheme()
        navigationController?.navigationBar.applyTheme()
    }
}
