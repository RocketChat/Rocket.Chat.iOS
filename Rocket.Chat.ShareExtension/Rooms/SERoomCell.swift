//
//  SERoomTableViewCell.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage

class SERoomCell: UITableViewCell, SECell {
    @IBOutlet weak var avatarView: SEAvatarView!
    @IBOutlet weak var nameLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarView.prepareForReuse()
        nameLabel.text = ""
    }

    var cellModel = SERoomCellModel(room: Subscription(), avatarBaseUrl: "") {
        didSet {
            nameLabel.text = cellModel.name
            avatarView.name = cellModel.name

            if cellModel.room.type == .directMessage,
                let name = cellModel.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {
                avatarView.setImageUrl("\(cellModel.avatarBaseUrl)/\(name)")
            }
        }
    }
}
