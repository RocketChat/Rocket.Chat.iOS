//
//  SubscriptionCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/4/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class SubscriptionCell: UITableViewCell {

    static let identifier = "CellSubscription"

    internal let defaultBackgroundColor = UIColor.white
    internal let selectedBackgroundColor = #colorLiteral(red: 0.4980838895, green: 0.4951269031, blue: 0.5003594756, alpha: 0.19921875)
    internal let highlightedBackgroundColor = #colorLiteral(red: 0.4980838895, green: 0.4951269031, blue: 0.5003594756, alpha: 0.09530179799)

    var subscription: Subscription? {
        didSet {
            guard let subscription = subscription, !subscription.isInvalidated else { return }
            updateSubscriptionInformatin()
        }
    }

    @IBOutlet weak var viewStatus: UIView! {
        didSet {
            viewStatus.backgroundColor = .RCInvisible()
            viewStatus.layer.masksToBounds = true
            viewStatus.layer.cornerRadius = 5
        }
    }

    weak var avatarView: AvatarView!
    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarViewContainer.layer.cornerRadius = 4
            avatarViewContainer.layer.masksToBounds = true

            if let avatarView = AvatarView.instantiateFromNib() {
                avatarView.frame = avatarViewContainer.bounds
                avatarViewContainer.addSubview(avatarView)
                self.avatarView = avatarView
            }
        }
    }

    @IBOutlet weak var labelDateRightSpacingConstraint: NSLayoutConstraint! {
        didSet {
            labelDateRightSpacingConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? -8 : 0
        }
    }

    @IBOutlet weak var labelUnreadRightSpacingConstraint: NSLayoutConstraint! {
        didSet {
            labelUnreadRightSpacingConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 0
        }
    }

    @IBOutlet weak var iconRoom: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLastMessage: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUnread: UILabel!
    @IBOutlet weak var viewUnread: UIView! {
        didSet {
            viewUnread.layer.cornerRadius = 4
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarView.prepareForReuse()

        labelName.text = nil
        labelLastMessage.text = nil
        labelUnread.text = nil
        viewUnread.isHidden = true
    }

    func updateSubscriptionInformatin() {
        guard let subscription = self.subscription else { return }

        updateStatus(subscription: subscription)

        if let user = subscription.directMessageUser {
            avatarView.subscription = nil
            avatarView.user = user
        } else {
            avatarView.user = nil
            avatarView.subscription = subscription
        }

        labelName.text = subscription.displayName()
        labelLastMessage.text = subscription.roomLastMessageText

        let nameFontSize = labelName.font.pointSize
        let lastMessageFontSize = labelLastMessage.font.pointSize

        if let roomLastMessage = subscription.roomLastMessage?.createdAt {
            labelDate.text = dateFormatted(date: roomLastMessage)
        } else {
            labelDate.text = nil
        }

        if subscription.unread > 0 || subscription.alert {
            labelName.font = UIFont.systemFont(ofSize: nameFontSize, weight: .semibold)
            labelLastMessage.font = UIFont.systemFont(ofSize: lastMessageFontSize, weight: .medium)

            if subscription.unread > 0 {
                viewUnread.isHidden = false

                if subscription.groupMentions > 0 || subscription.userMentions > 0 {
                    labelUnread.text =  "@\(subscription.unread)"
                } else {
                    labelUnread.text =  "\(subscription.unread)"
                }
            } else {
                viewUnread.isHidden = true
                labelUnread.text = nil
            }
        } else {
            labelName.font = UIFont.systemFont(ofSize: nameFontSize, weight: .medium)
            labelLastMessage.font = UIFont.systemFont(ofSize: lastMessageFontSize, weight: .regular)

            viewUnread.isHidden = true
            labelUnread.text =  nil
        }

        applyTheme()
    }

    fileprivate func updateStatus(subscription: Subscription) {
        if subscription.type == .directMessage {
            viewStatus.isHidden = false
            iconRoom.isHidden = true

            if let user = subscription.directMessageUser {
                switch user.status {
                case .online: viewStatus.backgroundColor = .RCOnline()
                case .busy: viewStatus.backgroundColor = .RCBusy()
                case .away: viewStatus.backgroundColor = .RCAway()
                case .offline: viewStatus.backgroundColor = .RCInvisible()
                }
            }
        } else {
            iconRoom.isHidden = false
            viewStatus.isHidden = true

            if subscription.type == .channel {
                iconRoom.image = UIImage(named: "Cell Subscription Hashtag")
            } else {
                iconRoom.image = UIImage(named: "Cell Subscription Lock")
            }
        }
    }

    // Need to localize this formatting
    func dateFormatted(date: Date) -> String {
        let calendar = NSCalendar.current

        if calendar.isDateInYesterday(date) {
            return localized("subscriptions.list.date.yesterday")
        }

        if calendar.isDateInToday(date) {
            return RCDateFormatter.time(date)
        }

        return RCDateFormatter.date(date, dateStyle: .short)
    }

    func shouldUpdateForSubscription(_ subscription: Subscription) -> Bool {
        guard
            let lastMessageText = subscription.roomLastMessageText,
            let lastMessageDate = subscription.roomLastMessageDate
        else {
            return false
        }

        let isNameDifferent = labelName.text != subscription.displayName()
        let isLastMessageDifferent = labelLastMessage.text != lastMessageText
        let isDateDifferent = labelDate.text != dateFormatted(date: lastMessageDate)

        return isNameDifferent || isLastMessageDifferent || isDateDifferent
    }

}

extension SubscriptionCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        let transition = {
            switch selected {
            case true:
                self.backgroundColor = self.selectedBackgroundColor
            case false:
                self.backgroundColor = self.theme?.backgroundColor ?? self.defaultBackgroundColor
            }
        }

        if animated {
            UIView.animate(withDuration: 0.18, animations: transition)
        } else {
            transition()
        }
    }

    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        let transition = {
            switch highlighted {
            case true:
                self.backgroundColor = self.highlightedBackgroundColor
            case false:
                self.backgroundColor = self.theme?.backgroundColor ?? self.defaultBackgroundColor
            }
        }

        if animated {
            UIView.animate(withDuration: 0.18, animations: transition)
        } else {
            transition()
        }
    }
}

// MARK: Themeable

extension SubscriptionCell {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }

        labelName.textColor = theme.titleText
        viewUnread.backgroundColor = theme.tintColor
        labelUnread.backgroundColor = theme.tintColor
        labelUnread.textColor = theme.backgroundColor
        labelLastMessage.textColor = theme.auxiliaryText
        iconRoom.tintColor = theme.auxiliaryText

        setSelected(isSelected, animated: false)
        setHighlighted(isHighlighted, animated: false)

        guard let subscription = self.subscription, !subscription.isInvalidated else {
            return
        }

        if subscription.unread > 0 || subscription.alert {
            labelDate.textColor = theme.tintColor
        } else {
            labelDate.textColor = theme.auxiliaryText
        }
    }
}
