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
    var fieldsStackHeightInitialConstant: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        fieldsStackHeightInitialConstant = fieldsStackViewHeightConstraint.constant

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        contentViewWidthConstraint.isActive = true
    }

    func configure() {
        guard let viewModel = viewModel?.base as? TextAttachmentChatItem else {
            return
        }

        title.text = viewModel.attachment.title

        if let subtitleText = viewModel.attachment.descriptionText {
            // TODO: Adjust constraints for valid subtitle
            subtitle.text = subtitleText
        } else {
            // TODO: Adjust constraints for no subtitle
        }

        var stackViewHeight: CGFloat = 0
        var attachmentFieldViews: [AttachmentFieldView] = []

        for attachmentField in viewModel.attachment.fields {
            guard let attachmentFieldView = AttachmentFieldView.instantiateFromNib() else {
                continue
            }

            attachmentFieldView.field.text = attachmentField.title
            attachmentFieldView.value.text = attachmentField.value

            let maxSize = CGSize(width: fieldLabelWidth, height: .greatestFiniteMagnitude)
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

    override func prepareForReuse() {
        super.prepareForReuse()

        fieldsStackView.arrangedSubviews.forEach { subview in
            fieldsStackView.removeArrangedSubview(subview)
            subview.removeFromSuperview()
        }

        fieldsStackViewHeightConstraint.constant = fieldsStackHeightInitialConstant
    }
}
