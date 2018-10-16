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
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var subtitle: UILabel!
    @IBOutlet weak var statusView: UIView!
    @IBOutlet weak var arrow: UIImageView!
    @IBOutlet weak var fieldsStackView: UIStackView!

    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var textContainerLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var statusViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var subtitleTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var fieldsStackViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textContainerTrailingConstraint: NSLayoutConstraint!

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
        statusViewLeadingInitialConstant = statusViewLeadingConstraint.constant
        statusViewWidthInitialConstant = statusViewWidthConstraint.constant
        fieldsStackViewLeadingInitialConstant = fieldsStackViewLeadingConstraint.constant
        fieldsStackViewTrailingInitialConstant = fieldsStackViewTrailingConstraint.constant
        textContainerTrailingInitialConstant = textContainerTrailingConstraint.constant

        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapTextContainerView))
        gesture.delegate = self
        textContainer.addGestureRecognizer(gesture)
    }

    override func configure() {
        guard let viewModel = viewModel?.base as? TextAttachmentChatItem else {
            return
        }

        title.text = viewModel.attachment.title
        configure(with: avatarView, date: date, and: username)

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

        reset(stackView: fieldsStackView)
        fieldsStackViewTopConstraint.constant = 0
        fieldsStackViewHeightConstraint.constant = 0
    }

    func configureExpandedState(with viewModel: TextAttachmentChatItem) {
        arrow.image = #imageLiteral(resourceName: "Attachment Expanded Light")

        if let subtitleText = viewModel.attachment.text {
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
