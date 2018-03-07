//
//  SEServerTableViewCell.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage

class SEServerTableViewCell: UITableViewCell, SETableViewRegisterable {
    @IBOutlet weak var iconView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var hostLabel: UILabel!

    var viewModel = SEServerCellViewModel(iconUrl: "", name: "", host: "", selected: false) {
        didSet {
            iconView.sd_setImage(with: URL(string: viewModel.iconUrl), completed: nil)
            nameLabel.text = viewModel.name
            hostLabel.text = viewModel.host
            accessoryType = viewModel.selected ? .checkmark : .none
        }
    }
}
