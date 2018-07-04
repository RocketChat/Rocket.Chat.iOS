//
//  UserDetailHeaderView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/29/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class UserDetailHeaderView: UIView {
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!

    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var voiceCallButton: UIButton!
    @IBOutlet weak var videoCallButton: UIButton!
}

// MARK: Themeable

extension UserDetailHeaderView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        usernameLabel?.textColor = theme.auxiliaryText
    }
}
