//
//  ChangeAppIconView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 5/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class ChangeAppIconView: UIView { }

// MARK: Themeable

extension ChangeAppIconView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        backgroundColor = theme == .light ? #colorLiteral(red: 0.9372549057, green: 0.9372549057, blue: 0.9568627477, alpha: 1) : theme.focusedBackground
    }
}
