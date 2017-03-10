//
//  ChannelInfoUserCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ChannelInfoUserCell: UITableViewCell {

    static let identifier = "kChannelInfoCellUser"

    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!

}
