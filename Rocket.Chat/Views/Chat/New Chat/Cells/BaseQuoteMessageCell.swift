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
            UIScreen.main.bounds.width -
            avatarLeadingInitialConstant -
            avatarWidthInitialConstant -
            containerLeadingInitialConstant -
            textLeadingInitialConstant -
            textTrailingInitialConstant -
            containerTrailingInitialConstant -
            readReceiptWidthInitialConstant -
            readReceiptTrailingInitialConstant -
            adjustedHorizontalInsets
    }

    var isCollapsible = false
    weak var delegate: ChatMessageCellProtocol?

    @objc func didTapContainerView() {
        guard
            isCollapsible,
            let viewModel = viewModel,
            let quoteViewModel = viewModel.base as? QuoteChatItem
        else {
            return
        }

        quoteViewModel.toggle()
        delegate?.viewDidCollapseChange(viewModel: viewModel)
    }
}

extension BaseQuoteMessageCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
