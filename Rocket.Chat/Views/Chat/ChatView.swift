//
//  ChatView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/27/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatView: UIView {
    @IBOutlet weak var scrollToBottomButton: UIButton!
}

extension ChatView {
    override var theme: Theme? { return ThemeManager.theme }

    override func applyTheme(_ theme: Theme) {
        super.applyTheme(theme)
        scrollToBottomButton.tintColor = theme.titleText
        scrollToBottomButton.layer.borderColor = theme.auxiliaryText.cgColor
    }
}
