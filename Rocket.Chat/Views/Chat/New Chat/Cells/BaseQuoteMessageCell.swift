//
//  BaseQuoteMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 17/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class BaseQuoteMessageCell: BaseMessageCell {
    internal let collapsedTextMaxHeight: CGFloat = 60

    var textHeightConstraint: NSLayoutConstraint!
    var purposeHeightInitialConstant: CGFloat = 0
    var avatarLeadingInitialConstant: CGFloat = 0
    var avatarWidthInitialConstant: CGFloat = 0
    var containerLeadingInitialConstant: CGFloat = 0
    var textLeadingInitialConstant: CGFloat = 0
    var textTrailingInitialConstant: CGFloat = 0
    var containerTrailingInitialConstant: CGFloat = 0
    var readReceiptWidthInitialConstant: CGFloat = 0
    var readReceiptTrailingInitialConstant: CGFloat = 0
    var textLabelWidth: CGFloat {
        return
            messageWidth -
            avatarLeadingInitialConstant -
            avatarWidthInitialConstant -
            containerLeadingInitialConstant -
            textLeadingInitialConstant -
            textTrailingInitialConstant -
            containerTrailingInitialConstant -
            readReceiptWidthInitialConstant -
            readReceiptTrailingInitialConstant -
            layoutMargins.left -
            layoutMargins.right
    }

    var isCollapsible = false

    @objc func didTapContainerView() {
        guard
            isCollapsible,
            let viewModel = viewModel,
            let chatItem = viewModel.base as? QuoteChatItem
        else {
            return
        }

        messageSection?.collapsibleItemsState[viewModel.differenceIdentifier] = !chatItem.collapsed
        delegate?.viewDidCollapseChange(viewModel: viewModel)
    }

    // swiftlint:disable function_parameter_count
    func configure(
        purpose: UILabel,
        purposeHeightConstraint: NSLayoutConstraint,
        username: UILabel,
        text: UILabel,
        textHeightConstraint: NSLayoutConstraint,
        arrow: UIImageView
    ) {
        guard let viewModel = viewModel?.base as? QuoteChatItem else {
            return
        }

        purpose.text = viewModel.purpose
        purposeHeightConstraint.constant = viewModel.purpose.isEmpty ? 0 : purposeHeightInitialConstant

        let attachmentText = Emojione.transform(string: viewModel.text ?? "")
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
