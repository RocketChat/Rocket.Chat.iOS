//
//  ChannelInfoDescriptionCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct ChannelInfoDescriptionCellData: ChannelInfoCellDataProtocol {
    let cellType = ChannelInfoDescriptionCell.self
    var title: String?
    var description: String?
}

final class ChannelInfoDescriptionCell: UITableViewCell, ChannelInfoCellProtocol {

    static let identifier = "kChannelInfoCellDescription"
    static let defaultHeight: Float = 80

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDescription: UILabel! {
        didSet {
            labelDescription.textColor = UIColor.RCGray()
        }
    }

    var data: ChannelInfoDescriptionCellData? {
        didSet {
            labelTitle.text = data?.title
            labelDescription.text = data?.description
        }
    }

}
