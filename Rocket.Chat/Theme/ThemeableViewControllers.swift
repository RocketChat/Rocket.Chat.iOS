//
//  ThemeableViewControllers.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 5/2/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIViewController: Themeable {

    /**
     Calls the `applyTheme` on the `view` and the `navigationController`.

     - Important:
     On first initializaiton, it is recommended that the view controller be added as an observer to the ThemeManager using the `ThemeManager.addObserver(_:)` method.
     */

    func applyTheme() {
        view.applyTheme()
        navigationController?.navigationBar.applyTheme()
    }
}
