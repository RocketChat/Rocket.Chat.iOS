//
//  ChannelInfoUserCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct ChannelInfoUserCellData: ChannelInfoCellDataProtocol {
    let cellType = ChannelInfoUserCell.self
    var user: User?
}

final class ChannelInfoUserCell: UITableViewCell, ChannelInfoCellProtocol {
    typealias DataType = ChannelInfoUserCellData

    static let identifier = "kChannelInfoCellUser"
    static let defaultHeight: Float = 80

    var data: DataType? {
        didSet {
            labelTitle.text = data?.user?.name
            labelSubtitle.text = data?.user?.username
            avatarView.user = data?.user
        }
    }

    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            if let avatarView = AvatarView.instantiateFromNib() {
                avatarView.frame = avatarViewContainer.bounds
                avatarViewContainer.addSubview(avatarView)
                self.avatarView = avatarView
            }
        }
    }

    weak var avatarView: AvatarView! {
        didSet {
            avatarView.layer.cornerRadius = 4
            avatarView.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!

}
