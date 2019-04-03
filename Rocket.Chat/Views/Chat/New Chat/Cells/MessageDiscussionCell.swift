//
//  MessageActionsCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 22/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
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
        guard
            let model = viewModel?.base as? MessageDiscussionChatItem,
            let message = model.message
        else {
            return
        }

        let buttonTitle = String(format: "%d messages", message.discussionMessagesCount)
        discussionButton.setTitle(buttonTitle, for: .normal)

        labelMessage.text = message.text
        messageTextViewHeightConstraint.constant = labelMessage.sizeThatFits(CGSize(
            width: textWidth,
            height: .greatestFiniteMagnitude)
        ).height

        if let lastMessageDate =  message.discussionLastMessage {
            labelDiscussionLastMessage.text = formatLastMessageDate(lastMessageDate)
        } else {
            labelDiscussionLastMessage.text = ""
        }
    }

    @IBAction func buttonDiscussionDidPressed(sender: Any) {
        guard
            let model = viewModel?.base as? MessageDiscussionChatItem,
            let rid = model.message?.discussionRid,
            let subscription = Subscription.find(rid: rid)
        else {
            return
        }

        AppManager.open(room: subscription)
    }

    func formatLastMessageDate(_ date: Date) -> String {
        let calendar = Calendar.current

        if calendar.isDateInYesterday(date) {
            return localized("subscriptions.list.date.yesterday")
        }

        if calendar.isDateInToday(date) {
            return RCDateFormatter.time(date)
        }

        return RCDateFormatter.date(date, dateStyle: .short)
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
