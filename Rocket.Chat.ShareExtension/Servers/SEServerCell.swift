//
//  SEServerTableViewCell.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage

class SEServerCell: UITableViewCell, SECell {
    @IBOutlet weak var avatarView: SEAvatarView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!

    var cellModel = SEServerCellModel(iconUrl: "", name: "", host: "", selected: false) {
        didSet {
            avatarView.name = cellModel.name
            avatarView.setImageUrl(cellModel.iconUrl)
            nameLabel.text = cellModel.name
            hostLabel.text = cellModel.host
            accessoryType = cellModel.selected ? .checkmark : .none
        }
    }
}
