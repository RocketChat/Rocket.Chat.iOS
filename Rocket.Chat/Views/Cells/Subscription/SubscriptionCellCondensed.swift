//
//  SubscriptionCellCondensed.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 04/07/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

final class SubscriptionCellCondensed: UITableViewCell {

    static let identifier = "CellSubscriptionCondensed"

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

    @IBOutlet weak var labelUnreadRightSpacingConstraint: NSLayoutConstraint! {
        didSet {
            labelUnreadRightSpacingConstraint.constant = UIDevice.current.userInterfaceIdiom == .pad ? 8 : 0
        }
    }

    @IBOutlet weak var iconRoom: UIImageView!
    @IBOutlet weak var labelName: UILabel!
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

        let nameFontSize = labelName.font.pointSize

        if subscription.unread > 0 || subscription.alert {
            labelName.font = UIFont.systemFont(ofSize: nameFontSize, weight: .semibold)

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

            viewUnread.isHidden = true
            labelUnread.text =  nil
        }

        applyTheme()
    }

    var userStatus: UserStatus? {
        didSet {
            if let userStatus = userStatus {
                switch userStatus {
                case .online: viewStatus.backgroundColor = .RCOnline()
                case .busy: viewStatus.backgroundColor = .RCBusy()
                case .away: viewStatus.backgroundColor = .RCAway()
                case .offline: viewStatus.backgroundColor = .RCInvisible()
                }
            }
        }
    }

    fileprivate func updateStatus(subscription: Subscription) {
        if subscription.type == .directMessage {
            viewStatus.isHidden = false
            iconRoom.isHidden = true

            if let user = subscription.directMessageUser {
                userStatus = user.status
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

    func shouldUpdateForSubscription(_ subscription: Subscription) -> Bool {
        let isNameDifferent = labelName.text != subscription.displayName()
        let isStatusDifferent = userStatus != subscription.otherUserStatus
        let isUnreadDifferent = labelUnread.text != "\(subscription.unread)"

        return isNameDifferent || isStatusDifferent || isUnreadDifferent
    }

}

extension SubscriptionCellCondensed {

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

extension SubscriptionCellCondensed {

    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }

        labelName.textColor = theme.titleText
        viewUnread.backgroundColor = theme.tintColor
        labelUnread.backgroundColor = theme.tintColor
        labelUnread.textColor = theme.backgroundColor
        iconRoom.tintColor = theme.auxiliaryText

        setSelected(isSelected, animated: false)
        setHighlighted(isHighlighted, animated: false)
    }

}
