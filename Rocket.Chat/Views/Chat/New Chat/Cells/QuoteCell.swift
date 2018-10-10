//
//  QuoteCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 03/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class QuoteCell: UICollectionViewCell, ChatCell, SizingCell {
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
    var textLabelWidth: CGFloat {
        return
            UIScreen.main.bounds.width -
            containerLeadingConstraint.constant -
            textLeadingConstraint.constant -
            textTrailingConstraint.constant -
            containerTrailingConstraint.constant
    }

    internal let collapsedTextMaxHeight: CGFloat = 60
    var textHeightConstraint: NSLayoutConstraint!
    var expandedTextHeightConstraint: NSLayoutConstraint!
    var isCollapsible = false
    weak var delegate: ChatMessageCellProtocol?

    var adjustedHorizontalInsets: CGFloat = 0
    var viewModel: AnyChatItem?
    var contentViewWidthConstraint: NSLayoutConstraint!

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

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        contentViewWidthConstraint.isActive = true

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapContainerView))
        gesture.delegate = self
        containerView.addGestureRecognizer(gesture)
    }

    func configure() {
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

extension QuoteCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}
