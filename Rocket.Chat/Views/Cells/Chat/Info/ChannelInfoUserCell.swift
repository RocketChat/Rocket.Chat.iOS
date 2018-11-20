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
    static let defaultHeight: CGFloat = 80

    var data: DataType? {
        didSet {
            labelTitle.text = data?.user?.name
            labelSubtitle.text = data?.user?.username
            avatarView.username = data?.user?.username
        }
    }

    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarView.frame = avatarViewContainer.bounds
            avatarViewContainer.addSubview(avatarView)
        }
    }

    lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.layer.cornerRadius = 4
        avatarView.layer.masksToBounds = true
        return avatarView
    }()

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!

}
