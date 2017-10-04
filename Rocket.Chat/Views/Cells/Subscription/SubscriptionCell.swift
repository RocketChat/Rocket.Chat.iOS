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

    internal let defaultBackgroundColor = UIColor.clear
    internal let selectedBackgroundColor = UIColor(rgb: 0x0, alphaVal: 0.18)
    internal let highlightedBackgroundColor = UIColor(rgb: 0x0, alphaVal: 0.27)

    var subscription: Subscription? {
        didSet {
            updateSubscriptionInformatin()
        }
    }

    @IBOutlet weak var viewStatus: UIView! {
        didSet {
            viewStatus.layer.masksToBounds = true
            viewStatus.layer.cornerRadius = 3
        }
    }

    weak var avatarView: AvatarView!
    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarViewContainer.layer.cornerRadius = 4
            avatarViewContainer.layer.masksToBounds = true

            if let avatarView = AvatarView.instantiateFromNib() {
                avatarView.frame = avatarViewContainer.bounds
                avatarView.layer.cornerRadius = 4
                avatarView.layer.masksToBounds = true
                avatarViewContainer.addSubview(avatarView)
                self.avatarView = avatarView
            }
        }
    }

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUnread: UILabel! {
        didSet {
            labelUnread.layer.cornerRadius = 2
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        avatarView.user = nil
        avatarView.subscription = nil
        labelName.text = ""
        labelUnread.text = ""
        labelUnread.alpha = 0
    }

    func updateSubscriptionInformatin() {
        guard let subscription = self.subscription else { return }

        updateStatus()

        avatarView.subscription = subscription
        avatarView.user = subscription.directMessageUser
        labelName.text = subscription.displayName()

        let nameFontSize = labelName.font.pointSize
        let dateFontSize = labelDate.font.pointSize

        if subscription.unread > 0 {
            labelName.font = UIFont.boldSystemFont(ofSize: nameFontSize)
            labelDate.font = UIFont.boldSystemFont(ofSize: dateFontSize)
            labelDate.textColor = .black

            labelUnread.alpha = 1
            labelUnread.text =  "\(subscription.unread)"
        } else {
            labelName.font = UIFont.systemFont(ofSize: nameFontSize)
            labelDate.font = UIFont.systemFont(ofSize: dateFontSize)
            labelDate.textColor = .RCGray()

            labelUnread.alpha = 0
            labelUnread.text =  ""
        }

        if let roomUpdatedAt = subscription.roomUpdatedAt {
            labelDate.text = dateFormatted(date: roomUpdatedAt)
        }
    }

    func updateStatus() {
        guard let subscription = self.subscription else { return }

        if subscription.type == .directMessage {
            var color: UIColor = .RCInvisible()

            if let user = subscription.directMessageUser {
                color = { _ -> UIColor in
                    switch user.status {
                        case .online: return .RCOnline()
                        case .offline: return .RCInvisible()
                        case .away: return .RCAway()
                        case .busy: return .RCBusy()
                    }
                }(())
            }

            viewStatus.isHidden = false
            viewStatus.backgroundColor = color
        } else {
            viewStatus.isHidden = true
        }
    }

    // Need to localize this formatting
    func dateFormatted(date: Date) -> String {
        let calendar = NSCalendar.current

        if calendar.isDateInYesterday(date) {
            return "Yesterday"
        }

        if calendar.isDateInToday(date) {
            return date.formatted("HH:mm")
        }

        return date.formatted("dd/MM/yyyy")
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
