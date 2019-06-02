//
//  ChannelInfoBasicCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RCMarkdownParser

struct ChannelInfoBasicCellData: ChannelInfoCellDataProtocol {
    let cellType = ChannelInfoBasicCell.self
    var title: String?
}

final class ChannelInfoBasicCell: UITableViewCell, ChannelInfoCellProtocol {
    typealias DataType = ChannelInfoBasicCellData

    static let identifier = "kChannelInfoCellBasic"
    static let defaultHeight: CGFloat = UITableView.automaticDimension

    var data: DataType? {
        didSet {
            labelTitle.text = data?.title
            labelTitle.textColor = .RCDarkGray()
            labelTitle.font = UIFont.boldSystemFont(ofSize: labelTitle.font.pointSize)
        }
    }

    @IBOutlet weak var labelTitle: UILabel!

}
