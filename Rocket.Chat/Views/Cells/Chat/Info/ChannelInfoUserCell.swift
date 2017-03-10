//
//  ChannelInfoUserCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ChannelInfoUserCell: UITableViewCell, ChannelInfoCellProtocol {

    static let identifier = "kChannelInfoCellUser"
    static let defaultHeight: Float = 80

    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!

}
