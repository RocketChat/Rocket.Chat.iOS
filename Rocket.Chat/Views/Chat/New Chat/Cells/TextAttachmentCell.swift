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
    @IBOutlet weak var subtitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewTopConstraint: NSLayoutConstraint!
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
    var subtitleHeightConstraint: NSLayoutConstraint!
    var emptySubtitleHeightConstraint: NSLayoutConstraint!
    var fieldsStackTopInitialConstant: CGFloat = 0
    var fieldsStackHeightInitialConstant: CGFloat = 0
    var subtitleHeightInitialConstant: CGFloat = 0
    var subtitleTopInitialConstant: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        emptySubtitleHeightConstraint = NSLayoutConstraint(
            item: subtitle,
            attribute: .height,
            relatedBy: .equal,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 0
        )

        subtitleHeightConstraint = NSLayoutConstraint(
            item: subtitle,
            attribute: .height,
            relatedBy: .greaterThanOrEqual,
            toItem: nil,
            attribute: .notAnAttribute,
            multiplier: 0,
            constant: 16
        )

        emptySubtitleHeightConstraint.isActive = false
        subtitleHeightConstraint.isActive = true

        fieldsStackTopInitialConstant = fieldsStackViewTopConstraint.constant
        fieldsStackHeightInitialConstant = fieldsStackViewHeightConstraint.constant
        subtitleTopInitialConstant = subtitleTopConstraint.constant
        subtitleHeightInitialConstant = subtitleHeightConstraint.constant

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        contentViewWidthConstraint.isActive = true
    }

    func configure() {
        guard let viewModel = viewModel?.base as? TextAttachmentChatItem else {
            return
        }

        title.text = viewModel.attachment.title

        if viewModel.attachment.collapsed {
            configureCollapsedState(with: viewModel)
        } else {
            configureExpandedState(with: viewModel)
        }
    }

    func configureCollapsedState(with viewModel: TextAttachmentChatItem) {
        arrow.image = #imageLiteral(resourceName: "Attachment Collapsed Light")
        subtitleHeightConstraint.isActive = false
        emptySubtitleHeightConstraint.isActive = true
        subtitleTopConstraint.constant = 0
        emptySubtitleHeightConstraint.constant = 0
        subtitle.text = ""

        resetFieldsStackView()
        fieldsStackViewTopConstraint.constant = 0
        fieldsStackViewHeightConstraint.constant = 0
    }

    func configureExpandedState(with viewModel: TextAttachmentChatItem) {
        arrow.image = #imageLiteral(resourceName: "Attachment Expanded Light")

        if let subtitleText = viewModel.attachment.text {
            emptySubtitleHeightConstraint.isActive = false
            subtitleHeightConstraint.isActive = true
            subtitleTopConstraint.constant = subtitleTopInitialConstant
            subtitleHeightConstraint.constant = subtitleHeightInitialConstant
            subtitle.text = subtitleText
        } else {
            subtitleHeightConstraint.isActive = false
            emptySubtitleHeightConstraint.isActive = true
            subtitleTopConstraint.constant = 0
            emptySubtitleHeightConstraint.constant = 0
            subtitle.text = ""
        }

        let maxSize = CGSize(width: fieldLabelWidth, height: .greatestFiniteMagnitude)
        var stackViewHeight: CGFloat = 0
        var attachmentFieldViews: [AttachmentFieldView] = []

        resetFieldsStackView()
        fieldsStackViewTopConstraint.constant = fieldsStackTopInitialConstant
        fieldsStackViewHeightConstraint.constant = fieldsStackHeightInitialConstant

        for attachmentField in viewModel.attachment.fields {
            guard let attachmentFieldView = AttachmentFieldView.instantiateFromNib() else {
                continue
            }

            let attributedValue = NSMutableAttributedString(string: attachmentField.value).transformMarkdown(with: theme)
            attachmentFieldView.field.text = attachmentField.title
            attachmentFieldView.value.attributedText = attributedValue

            let valueTextHeight = attachmentFieldView.value.sizeThatFits(maxSize).height
            let fieldViewHeight = attachmentFieldView.fieldHeightConstraint.constant +
                attachmentFieldView.valueTopConstraint.constant +
                valueTextHeight

            stackViewHeight += fieldViewHeight
            attachmentFieldView.contentSize = CGSize(width: fieldLabelWidth, height: fieldViewHeight)
            attachmentFieldView.invalidateIntrinsicContentSize()
            attachmentFieldViews.append(attachmentFieldView)
        }

        stackViewHeight += fieldsStackView.spacing * CGFloat(attachmentFieldViews.count - 1)
        fieldsStackViewHeightConstraint.constant = stackViewHeight

        layoutIfNeeded()

        attachmentFieldViews.forEach { view in
            fieldsStackView.addArrangedSubview(view)
        }
    }

    func resetFieldsStackView() {
        fieldsStackView.arrangedSubviews.forEach { subview in
            fieldsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        resetFieldsStackView()
        fieldsStackViewHeightConstraint.constant = fieldsStackHeightInitialConstant
    }
}
