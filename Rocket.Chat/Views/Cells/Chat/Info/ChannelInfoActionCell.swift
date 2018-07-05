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

    init(icon: UIImage?, title: String = "", detail: Bool = true, action: (() -> Void)? = nil) {
        self.icon = icon
        self.title = title
        self.action = action
        self.detail = detail
    }
}

class ChannelInfoActionCell: UITableViewCell, ChannelInfoCellProtocol {
    typealias DataType = ChannelInfoActionCellData

    static let identifier = "kChannelInfoActionCell"
    static let defaultHeight: CGFloat = 44
    var data: DataType? {
        didSet {
            labelTitle.text = data?.title
            imageViewIcon.image = data?.icon

            accessoryType = (data?.detail ?? false) ? .disclosureIndicator : .none
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!

}

extension ChannelInfoActionCell {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        imageViewIcon.tintColor = theme.titleText
    }
}
