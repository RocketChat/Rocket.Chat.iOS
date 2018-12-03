//
//  TextAttachmentMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 16/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class TextAttachmentMessageCell: BaseTextAttachmentMessageCell, SizingCell {
    static let identifier = String(describing: TextAttachmentMessageCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = TextAttachmentMessageCell.instantiateFromNib() else {
            return TextAttachmentMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.cornerRadius = 4
            avatarView.frame = avatarContainerView.bounds
            avatarContainerView.addSubview(avatarView)
        }
    }

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var statusView: UIImageView!
    @IBOutlet weak var textContainer: UIView! {
        didSet {
            textContainer.layer.borderWidth = 1
            textContainer.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var fieldsStackView: UIStackView!
    @IBOutlet weak var readReceiptButton: UIButton!
    @IBOutlet weak var statusColor: UIView!

    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var textContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusColorWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusColorLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textContainerTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var readReceiptButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var readReceiptTrailingConstraint: NSLayoutConstraint!

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
        avatarLeadingInitialConstant = avatarLeadingConstraint.constant
        avatarWidthInitialConstant = avatarWidthConstraint.constant
        textContainerLeadingInitialConstant = textContainerLeadingConstraint.constant
        statusColorLeadingInitialConstant = statusColorLeadingConstraint.constant
        statusColorWidthInitialConstant = statusColorWidthConstraint.constant
        fieldsStackViewLeadingInitialConstant = fieldsStackViewLeadingConstraint.constant
        fieldsStackViewTrailingInitialConstant = fieldsStackViewTrailingConstraint.constant
        textContainerTrailingInitialConstant = textContainerTrailingConstraint.constant
        readReceiptWidthInitialConstant = readReceiptButtonWidthConstraint.constant
        readReceiptTrailingInitialConstant = readReceiptTrailingConstraint.constant

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextContainerView))
        gesture.delegate = self
        textContainer.addGestureRecognizer(gesture)

        insertGesturesIfNeeded(with: username)
    }

    override func configure(completeRendering: Bool) {
        guard let viewModel = viewModel?.base as? TextAttachmentChatItem else {
            return
        }

        if completeRendering {
            let emptyTitle = localized("chat.components.text_attachment.no_title")
            title.text = viewModel.title.isEmpty ? emptyTitle : viewModel.title
            configure(statusColor: statusColor)
        }

        configure(readReceipt: readReceiptButton)
        configure(
            with: avatarView,
            date: date,
            status: statusView,
            and: username,
            completeRendering: completeRendering
        )

        if viewModel.collapsed {
            configureCollapsedState(with: viewModel)
        } else {
            configureExpandedState(with: viewModel)
        }
    }

    func configureCollapsedState(with viewModel: TextAttachmentChatItem) {
        arrow.image = theme == .light ?  #imageLiteral(resourceName: "Attachment Collapsed Light") : #imageLiteral(resourceName: "Attachment Collapsed Dark")
        subtitleHeightConstraint.isActive = false
        emptySubtitleHeightConstraint.isActive = true
        subtitleTopConstraint.constant = 0
        emptySubtitleHeightConstraint.constant = 0
        subtitle.text = ""

        reset(stackView: fieldsStackView)
        fieldsStackViewTopConstraint.constant = 0
        fieldsStackViewHeightConstraint.constant = 0
    }

    func configureExpandedState(with viewModel: TextAttachmentChatItem) {
        arrow.image = theme == .light ? #imageLiteral(resourceName: "Attachment Expanded Light") : #imageLiteral(resourceName: "Attachment Expanded Dark")

        if let subtitleText = viewModel.subtitle {
            emptySubtitleHeightConstraint.isActive = false
            subtitleHeightConstraint.isActive = true
            subtitleTopConstraint.constant = subtitleTopInitialConstant
            subtitle.text = subtitleText

            let maxSize = CGSize(width: fieldLabelWidth, height: .greatestFiniteMagnitude)
            let subtitleHeight = subtitle.sizeThatFits(maxSize).height
            subtitleHeightConstraint.constant = subtitleHeight
        } else {
            subtitleHeightConstraint.isActive = false
            emptySubtitleHeightConstraint.isActive = true
            subtitleTopConstraint.constant = 0
            emptySubtitleHeightConstraint.constant = 0
            subtitle.text = ""
        }

        fieldsStackViewHeightConstraint.constant = configure(stackView: fieldsStackView)
    }
    override func prepareForReuse() {
        super.prepareForReuse()

        reset(stackView: fieldsStackView)
        fieldsStackViewTopConstraint.constant = fieldsStackTopInitialConstant
        fieldsStackViewHeightConstraint.constant = fieldsStackHeightInitialConstant
        subtitleTopConstraint.constant = subtitleTopInitialConstant
    }
}

extension TextAttachmentMessageCell {
    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        textContainer.backgroundColor = theme.chatComponentBackground
        fieldsStackView.backgroundColor = .clear
        username.textColor = theme.titleText
        date.textColor = theme.auxiliaryText
        title.textColor = theme.controlText
        subtitle.textColor = theme.bodyText
        textContainer.layer.borderColor = theme.borderColor.cgColor

        configure(statusColor: statusColor)
    }
}
