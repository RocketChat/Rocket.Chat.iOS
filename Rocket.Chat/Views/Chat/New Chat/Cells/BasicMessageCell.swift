//
//  BasicMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 23/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class BasicMessageCell: UICollectionViewCell, ChatCell {
    static let identifier = String(describing: BasicMessageCell.self)

    static let sizingCell: BasicMessageCell = {
        guard let cell = BasicMessageCell.instantiateFromNib() else {
            return BasicMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var text: RCTextView!

    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    var textHorizontalMargins: CGFloat {
        return textLeadingConstraint.constant +
            textTrailingConstraint.constant +
            avatarWidthConstraint.constant +
            avatarLeadingConstraint.constant
    }

    var viewModel: AnyChatItem?
    var initialTextHeightConstant: CGFloat = 0
    var contentViewWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        initialTextHeightConstant = textHeightConstraint.constant

        contentView.translatesAutoresizingMaskIntoConstraints = false
        contentViewWidthConstraint = contentView.widthAnchor.constraint(equalToConstant: UIScreen.main.bounds.width)
        contentViewWidthConstraint.isActive = true
    }

    func configure() {
        guard let viewModel = viewModel?.base as? BasicMessageChatItem else {
            return
        }

        if let createdAt = viewModel.message.createdAt {
            date.text = RCDateFormatter.time(createdAt)
        }

        username.text = viewModel.user.username
        updateText()
    }

    func updateText(force: Bool = false) {
        guard let viewModel = viewModel?.base as? BasicMessageChatItem else {
            return
        }

        if let message = force ? MessageTextCacheManager.shared.update(for: viewModel.message.managedObject, with: theme) : MessageTextCacheManager.shared.message(for: viewModel.message.managedObject, with: theme) {
            contentViewWidthConstraint.constant = UIScreen.main.bounds.width
            if viewModel.message.temporary {
                message.setFontColor(MessageTextFontAttributes.systemFontColor(for: theme))
            } else if viewModel.message.failed {
                message.setFontColor(MessageTextFontAttributes.failedFontColor(for: theme))
            }

            text.message = message

            // FA NOTE: Using UIScreen.main bounds is fine because we are not using
            // section insets, but in the future we can create a mechanism that
            // discounts the UICollectionView's section insets from the main screen's bounds
            let screenWidth = UIScreen.main.bounds.width
            let maxSize = CGSize(
                width: screenWidth - textHorizontalMargins,
                height: .greatestFiniteMagnitude
            )

            textHeightConstraint.constant = text.textView.sizeThatFits(
                maxSize
            ).height
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        username.text = ""
        date.text = ""
        text.message = nil
        textHeightConstraint.constant = initialTextHeightConstant
    }
}

extension BasicMessageCell {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        date.textColor = theme.auxiliaryText
        username.textColor = theme.titleText
        updateText(force: true)
    }
}
