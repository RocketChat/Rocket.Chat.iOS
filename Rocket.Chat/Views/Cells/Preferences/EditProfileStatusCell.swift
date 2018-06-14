//
//  EditProfileStatusCell.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/12/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class EditProfileStatusCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!
}

// MARK: Themeable

extension EditProfileStatusCell {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }

        titleLabel.textColor = theme.titleText
        detailLabel.textColor = theme.auxiliaryText
    }
}
