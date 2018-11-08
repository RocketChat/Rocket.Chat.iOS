//
//  QuoteCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 03/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class QuoteCell: BaseQuoteMessageCell, SizingCell {
    static let identifier = String(describing: QuoteCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = QuoteCell.instantiateFromNib() else {
            return QuoteCell()
        }

        return cell
    }()

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var text: UILabel!
    @IBOutlet weak var arrow: UIImageView!

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

        let attachmentText = viewModel.text ?? ""
        let attributedText = NSMutableAttributedString(string: attachmentText).transformMarkdown(with: theme)
        username.text = viewModel.title
        text.attributedText = attributedText

        let maxSize = CGSize(width: textLabelWidth, height: .greatestFiniteMagnitude)
        let textHeight = text.sizeThatFits(maxSize).height

        if textHeight > collapsedTextMaxHeight {
            isCollapsible = true
            arrow.alpha = 1

            if viewModel.collapsed {
                arrow.image = theme == .light ?  #imageLiteral(resourceName: "Attachment Collapsed Light") : #imageLiteral(resourceName: "Attachment Collapsed Dark")
                textHeightConstraint.constant = collapsedTextMaxHeight
            } else {
                arrow.image = theme == .light ? #imageLiteral(resourceName: "Attachment Expanded Light") : #imageLiteral(resourceName: "Attachment Expanded Dark")
                textHeightConstraint.constant = textHeight
            }
        } else {
            isCollapsible = false
            textHeightConstraint.constant = textHeight
            arrow.alpha = 0
        }
    }
}

extension QuoteCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        containerView.backgroundColor = theme.chatComponentBackground
        username.textColor = theme.actionTintColor
        text.textColor = theme.bodyText
    }
}
