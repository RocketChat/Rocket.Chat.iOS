//
//  ChannelInfoBasicCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct ChannelInfoBasicCellData: ChannelInfoCellDataProtocol {
    let cellType = ChannelInfoBasicCell.self
    var title: String?
}

final class ChannelInfoBasicCell: UITableViewCell, ChannelInfoCellProtocol {

    static let identifier = "kChannelInfoCellBasic"
    static let defaultHeight: Float = 44
    var data: ChannelInfoBasicCellData? {
        didSet {
            labelTitle.text = data?.title
        }
    }

    @IBOutlet weak var labelTitle: UILabel!

}
