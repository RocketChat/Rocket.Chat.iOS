//
//  ServerInfoCell.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 6/13/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

class ServerInfoCell: UITableViewCell { }

// MARK: Themeable

extension ServerInfoCell {
    override func applyTheme() {
        super.applyTheme()

        textLabel?.textColor = theme?.titleText
        detailTextLabel?.textColor = theme?.titleText
    }
}
