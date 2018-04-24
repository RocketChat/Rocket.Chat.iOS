//
//  ChannelInfoDetailCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

struct ChannelInfoDetailCellData: ChannelInfoCellDataProtocol {
    let cellType = ChannelInfoDetailCell.self
    let title: String
    let detail: String

    let action: (() -> Void)?

    init(title: String, detail: String = "", action: (() -> Void)? = nil) {
        self.title = title
        self.detail = detail
        self.action = action
    }
}

final class ChannelInfoDetailCell: UITableViewCell, ChannelInfoCellProtocol {
    static let identifier = "kChannelInfoCellDetail"
    static let defaultHeight: Float = 44
    var data: ChannelInfoDetailCellData? {
        didSet {
            labelTitle.text = data?.title
            labelDetail.text = data?.detail
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelDetail: UILabel! {
        didSet {
            labelDetail.textColor = UIColor.RCLightGray()
        }
    }

}
