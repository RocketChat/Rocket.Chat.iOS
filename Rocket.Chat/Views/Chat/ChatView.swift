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

// MARK: Themeable

extension ChatView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        scrollToBottomButton.tintColor = theme.titleText
        scrollToBottomButton.layer.borderColor = theme.auxiliaryText.cgColor
    }
}
