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

    internal let labelSelectedTextColor = UIColor(rgb: 0xFFFFFF, alphaVal: 1)
    internal let labelReadTextColor = UIColor(rgb: 0x9ea2a4, alphaVal: 1)
    internal let labelUnreadTextColor = UIColor(rgb: 0xFFFFFF, alphaVal: 1)

    internal let defaultBackgroundColor = UIColor.white
    internal let selectedBackgroundColor = UIColor(rgb: 0x0, alphaVal: 0.08)
    internal let highlightedBackgroundColor = UIColor(rgb: 0x0, alphaVal: 0.14)

    var subscription: Subscription? {
        didSet {
            guard let subscription = subscription, !subscription.isInvalidated else { return }
            updateSubscriptionInformatin()
        }
    }

    @IBOutlet weak var viewStatus: UIView! {
        didSet {
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

    @IBOutlet weak var iconRoom: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelLastMessage: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUnread: UILabel! {
        didSet {
            labelUnread.layer.cornerRadius = 4
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarView.prepareForReuse()

        labelName.text = ""
        labelLastMessage.text = ""
        labelUnread.text = ""
        labelUnread.alpha = 0
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
        labelLastMessage.text = subscription.lastMessageText()

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
            labelDate.textColor = .RCBlue()

            if subscription.unread > 0 {
                labelUnread.alpha = 1
                labelUnread.text =  "\(subscription.unread)"
            } else {
                labelUnread.alpha = 0
                labelUnread.text =  ""
            }
        } else {
            labelName.font = UIFont.systemFont(ofSize: nameFontSize, weight: .medium)
            labelLastMessage.font = UIFont.systemFont(ofSize: lastMessageFontSize, weight: .regular)
            labelDate.textColor = .RCGray()

            labelUnread.alpha = 0
            labelUnread.text =  ""
        }
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

}

extension SubscriptionCell {

    override func setSelected(_ selected: Bool, animated: Bool) {
        let transition = {
            switch selected {
            case true:
                self.backgroundColor = self.selectedBackgroundColor
            case false:
                self.backgroundColor = self.defaultBackgroundColor
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
                self.backgroundColor = self.defaultBackgroundColor
            }
        }

        if animated {
            UIView.animate(withDuration: 0.18, animations: transition)
        } else {
            transition()
        }
    }
}
