//
//  UserDetailFieldCell.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/27/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class UserDetailFieldCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var detailLabel: UILabel!

    var model: UserDetailFieldCellModel = .emptyState {
        didSet {
            titleLabel.text = model.title
            detailLabel.text = model.detail
        }
    }
}
