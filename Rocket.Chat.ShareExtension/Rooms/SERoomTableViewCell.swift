//
//  SERoomTableViewCell.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 3/7/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage

class SERoomTableViewCell: UITableViewCell, SECell {
    @IBOutlet weak var avatarView: SERoomAvatarView!
    @IBOutlet weak var nameLabel: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarView.imageView.image = nil
        avatarView.initialsLabel.backgroundColor = UIColor.clear
        nameLabel.text = ""
    }

    var cellModel = SERoomCellModel(room: Subscription(), avatarBaseUrl: "") {
        didSet {
            nameLabel.text = cellModel.name

            if let first = cellModel.name.first {
                avatarView.initialsLabel.text = "\(first)".uppercased()
                avatarView.initialsLabel.backgroundColor = UIColor.forName(cellModel.name)
            }

            if cellModel.room.type == .directMessage,
                let name = cellModel.name.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed) {

                avatarView.imageView.sd_setImage(
                    with: URL(string: "\(cellModel.avatarBaseUrl)/\(name)"),
                    completed: nil
                )
            }
        }
    }
}
