//
//  SubscriptionsSortingSeparatorView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionsSortingSeparatorView: UIView {

    let separator: UIView

    override init(frame: CGRect) {

        let horizontalSpacing = 16.0
        self.separator = UIView(frame: CGRect(
            x: horizontalSpacing,
            y: Double(frame.height) / 2,
            width: Double(frame.width) - horizontalSpacing * 2,
            height: 0.33
        ))

        super.init(frame: frame)
        separator.backgroundColor = .RCLightGray()
        separator.autoresizingMask = .flexibleWidth
        addSubview(separator)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Themeable

extension SubscriptionsSortingSeparatorView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }

        separator.backgroundColor = theme.mutedAccent
    }
}
