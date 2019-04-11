//
//  UINavigationItemAccessibilityExtension.swift
//  Rocket.Chat
//
//  Created by Rudrank Riyam on 29/03/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

extension UINavigationItem {
    func applyMoreButtonAccessibility() {
        rightBarButtonItem?.accessibilityLabel = VOLocalizedString("auth.more.label")
    }

    func applyCloseButtonAccessibility() {
        leftBarButtonItem?.accessibilityLabel = VOLocalizedString("auth.close.label")
    }
}
