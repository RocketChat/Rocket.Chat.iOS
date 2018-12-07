//
//  UnreadMarkerCell.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 25/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class UnreadMarkerCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: UnreadMarkerCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = UnreadMarkerCell.instantiateFromNib() else {
            return UnreadMarkerCell()
        }

        return cell
    }()

    @IBOutlet weak var label: UILabel! {
        didSet {
            label.font = label.font.bold()
            label.text = localized("chat.unread_separator")
        }
    }

    @IBOutlet weak var separatorLeft: UIView!
    @IBOutlet weak var separatorRight: UIView!

    var messageWidth: CGFloat = 0
    var viewModel: AnyChatItem?

    func configure(completeRendering: Bool) {}
}

// MARK: Theming

extension UnreadMarkerCell {

    override func applyTheme() {
        super.applyTheme()

        label.textColor = .attention
        separatorLeft.backgroundColor = .attention
        separatorRight.backgroundColor = .attention
    }

}
