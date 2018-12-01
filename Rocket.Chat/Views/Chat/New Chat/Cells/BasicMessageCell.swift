//
//  BasicMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 23/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class BasicMessageCell: BaseMessageCell, SizingCell {
    static let identifier = String(describing: BasicMessageCell.self)

    // MARK: SizingCell

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = BasicMessageCell.instantiateFromNib() else {
            return BasicMessageCell()
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
    @IBOutlet weak var text: RCTextView!

    @IBOutlet weak var readReceiptButton: UIButton!

    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var readReceiptWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var readReceiptTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    var textWidth: CGFloat {
        return
            messageWidth -
            textLeadingConstraint.constant -
            textTrailingConstraint.constant -
            readReceiptWidthConstraint.constant -
            readReceiptTrailingConstraint.constant -
            avatarWidthConstraint.constant -
            avatarLeadingConstraint.constant -
            layoutMargins.left -
            layoutMargins.right
    }

    override var delegate: ChatMessageCellProtocol? {
        didSet {
            text.delegate = delegate
        }
    }

    var initialTextHeightConstant: CGFloat = 0

    override func awakeFromNib() {
        super.awakeFromNib()

        initialTextHeightConstant = textHeightConstraint.constant
        insertGesturesIfNeeded(with: username)
    }

    override func configure(completeRendering: Bool) {
        configure(
            with: avatarView,
            date: date,
            status: statusView,
            and: username,
            completeRendering: completeRendering
        )

        configure(readReceipt: readReceiptButton)
        updateText()
    }

    func updateText() {
        guard
            let viewModel = viewModel?.base as? BasicMessageChatItem,
            let message = viewModel.message
        else {
            return
        }

        if let messageText = MessageTextCacheManager.shared.message(for: message, with: theme) {
            if message.temporary {
                messageText.setFontColor(MessageTextFontAttributes.systemFontColor(for: theme))
            } else if message.failed {
                messageText.setFontColor(MessageTextFontAttributes.failedFontColor(for: theme))
            }

            text.message = messageText

            let maxSize = CGSize(
                width: textWidth,
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
        avatarView.prepareForReuse()
        textHeightConstraint.constant = initialTextHeightConstant
    }
}

// MARK: Theming

extension BasicMessageCell {

    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        date.textColor = theme.auxiliaryText
        username.textColor = theme.titleText
        updateText()
    }

}
