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

class ChannelInfoUserCell: UITableViewCell, ChannelInfoCellProtocol {
    typealias DataType = ChannelInfoUserCellData

    static let identifier = "kChannelInfoCellUser"
    static let defaultHeight: Float = 80
    var data: DataType? {
        didSet {
            labelTitle.text = data?.user?.username
            labelSubtitle.text = data?.user?.name
        }
    }

    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!

}
