//
//  ChannelInfoDescriptionCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/03/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit
import RCMarkdownParser

struct ChannelInfoDescriptionCellData: ChannelInfoCellDataProtocol {
    let cellType = ChannelInfoDescriptionCell.self

    var title: String?
    var descriptionText: String?
}

final class ChannelInfoDescriptionCell: UITableViewCell, ChannelInfoCellProtocol {
    typealias DataType = ChannelInfoDescriptionCellData

    static let identifier = "kChannelInfoCellDescription"
    static let defaultHeight: Float = 80

    var data: DataType? {
        didSet {
            labelTitle.text = data?.title
            labelTitle.textColor = .RCDarkGray()

            let attributedString = NSAttributedString(string: data?.descriptionText ?? "")
            labelSubtitle.attributedText = MarkdownManager.shared.transformAttributedString(attributedString)
            labelSubtitle.textColor = .RCGray()
        }
    }

    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var labelSubtitle: UILabel!

}
