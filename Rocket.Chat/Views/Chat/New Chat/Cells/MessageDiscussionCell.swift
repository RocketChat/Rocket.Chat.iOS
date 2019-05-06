//
//  MessageDiscussionCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 02/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class MessageDiscussionCell: BaseMessageCell, SizingCell {
    static let identifier = String(describing: MessageDiscussionCell.self)

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = MessageDiscussionCell.instantiateFromNib() else {
            return MessageDiscussionCell()
        }

        return cell
    }()

    var textWidth: CGFloat {
        return
            messageWidth -
            messageTextLeadingConstraint.constant -
            messageTextTrailingConstraint.constant -
            layoutMargins.left -
            layoutMargins.right
    }

    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var messageTextLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextViewHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var discussionButton: UIButton! {
        didSet {
            discussionButton.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var labelDiscussionLastMessage: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        insertGesturesIfNeeded(with: nil)
    }

    override func configure(completeRendering: Bool) {
        guard let model = viewModel?.base as? MessageDiscussionChatItem else {
            return
        }

        discussionButton.setTitle(model.buttonTitle, for: .normal)
        labelMessage.attributedText = model.discussionTitle
        labelDiscussionLastMessage.text = model.discussionLastMessageDate

        messageTextViewHeightConstraint.constant = labelMessage.sizeThatFits(CGSize(
            width: textWidth,
            height: .greatestFiniteMagnitude
        )).height
    }

    @IBAction func buttonDiscussionDidPressed(sender: Any) {
        guard
            let model = viewModel?.base as? MessageDiscussionChatItem,
            let rid = model.message?.discussionRid
        else {
            return
        }

        AppManager.openRoom(rid: rid, type: .group)
    }
}

// MARK: Theming

extension MessageDiscussionCell {

    override func applyTheme() {
        super.applyTheme()

        guard let theme = theme else { return }

        discussionButton.setTitleColor(.white, for: .normal)
        discussionButton.backgroundColor = theme.actionTintColor

        labelMessage.textColor = theme.bodyText
        labelDiscussionLastMessage.textColor = theme.auxiliaryText
    }

}
