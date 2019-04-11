//
//  UIButtonAccessibilityExtension.swift
//  Rocket.Chat
//
//  Created by Rudrank Riyam on 11/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

extension UIButton {
    func applyShowMoreButtonAccessibility() {
        accessibilityLabel = VOLocalizedString("auth.show_more_options.label")
    }

    func applyShowLessButtonAccessibility() {
        accessibilityLabel = VOLocalizedString("auth.show_less_options.label")
    }
}
