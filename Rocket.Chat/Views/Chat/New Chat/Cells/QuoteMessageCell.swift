//
//  QuoteMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 17/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class QuoteMessageCell: BaseQuoteMessageCell, SizingCell {
    static let identifier = String(describing: QuoteMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = QuoteMessageCell.instantiateFromNib() else {
            return QuoteMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var arrow: UIImageView!

    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var containerTrailingConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        textHeightConstraint = NSLayoutConstraint(
            item: text,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 20
        )

        textHeightConstraint.isActive = true

        avatarLeadingInitialConstant = avatarLeadingConstraint.constant
        avatarWidthInitialConstant = avatarWidthConstraint.constant
        containerLeadingInitialConstant = containerLeadingConstraint.constant
        textLeadingInitialConstant = textLeadingConstraint.constant
        textTrailingInitialConstant = textTrailingConstraint.constant
        containerTrailingInitialConstant = containerTrailingConstraint.constant

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainerView))
        gesture.delegate = self
        containerView.addGestureRecognizer(gesture)
    }

    override func configure() {
        guard let viewModel = viewModel?.base as? QuoteChatItem else {
            return
        }

        let attachmentText = viewModel.attachment.text ?? viewModel.attachment.descriptionText ?? ""
        let attributedText = NSMutableAttributedString(string: attachmentText).transformMarkdown(with: theme)
        username.text = viewModel.attachment.title
        text.attributedText = attributedText

        let maxSize = CGSize(width: textLabelWidth, height: .greatestFiniteMagnitude)
        let textHeight = text.sizeThatFits(maxSize).height

        if textHeight > collapsedTextMaxHeight {
            isCollapsible = true
            arrow.alpha = 1

            if viewModel.attachment.collapsed {
                arrow.image = #imageLiteral(resourceName: "Attachment Collapsed Light")
                textHeightConstraint.constant = collapsedTextMaxHeight
            } else {
                arrow.image = #imageLiteral(resourceName: "Attachment Expanded Light")
                textHeightConstraint.constant = textHeight
            }
        } else {
            isCollapsible = false
            textHeightConstraint.constant = textHeight
            arrow.alpha = 0
        }
    }
}
