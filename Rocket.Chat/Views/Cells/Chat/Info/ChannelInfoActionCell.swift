//
//  ChannelInfoActionCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct ChannelInfoActionCellData: ChannelInfoCellDataProtocol {
    let cellType = ChannelInfoActionCell.self

    var icon: UIImage?
    var title: String?
    var detail: Bool = false

    let action: (() -> Void)?

    init(icon: UIImage?, title: String = "", action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.action = action
        self.detail = true
    }
}

class ChannelInfoActionCell: UITableViewCell, ChannelInfoCellProtocol {
    typealias DataType = ChannelInfoActionCellData

    static let identifier = "kChannelInfoActionCell"
    static let defaultHeight: Float = 44
    var data: DataType? {
        didSet {
            labelTitle.text = data?.title
            imageViewIcon.image = data?.icon
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!

}
