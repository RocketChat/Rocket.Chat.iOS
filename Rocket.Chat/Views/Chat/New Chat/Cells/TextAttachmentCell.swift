//
//  TextAttachmentCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 30/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class TextAttachmentCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: TextAttachmentCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = TextAttachmentCell.instantiateFromNib() else {
            return TextAttachmentCell()
        }

        return cell
    }()

    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var fieldsStackView: UIStackView!

    @IBOutlet weak var textContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textContainerTrailingConstraint: NSLayoutConstraint!
    var fieldLabelWidth: CGFloat {
        return
            UIScreen.main.bounds.width -
            textContainerLeadingConstraint.constant -
            statusViewLeadingConstraint.constant -
            statusViewWidthConstraint.constant -
            fieldsStackViewLeadingConstraint.constant -
            fieldsStackViewTrailingConstraint.constant -
            textContainerTrailingConstraint.constant
    }


    weak var delegate: ChatMessageCellProtocol?

    var viewModel: AnyChatItem?
    var contentViewWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        contentViewWidthConstraint.isActive = true
    }

    func configure() {
    }
}
