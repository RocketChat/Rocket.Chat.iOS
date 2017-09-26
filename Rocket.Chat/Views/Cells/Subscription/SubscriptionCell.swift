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

    @IBOutlet weak var imageViewIcon: UIImageView!
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelUnread: UILabel! {
        didSet {
            labelUnread.layer.cornerRadius = 2
        }
    }

    func updateSubscriptionInformatin() {
        guard let subscription = self.subscription else { return }

        updateIconImage()

        labelName.text = subscription.displayName()

        if subscription.unread > 0 || subscription.alert {
            labelName.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.headline)
            labelName.textColor = labelUnreadTextColor
        } else {
            labelName.font = UIFont.preferredFont(forTextStyle: UIFontTextStyle.body)
            labelName.textColor = labelReadTextColor
        }

        labelUnread.alpha = subscription.unread > 0 ? 1 : 0
        labelUnread.text = "\(subscription.unread)"
    }

    func updateIconImage() {
        guard let subscription = self.subscription else { return }

        switch subscription.type {
        case .channel:
            imageViewIcon.image = UIImage(named: "Hashtag")?.imageWithTint(.RCInvisible())
            break
        case .directMessage:
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

            imageViewIcon.image = UIImage(named: "Mentions")?.imageWithTint(color)
            break
        case .group:
            imageViewIcon.image = UIImage(named: "Lock")?.imageWithTint(.RCInvisible())
            break
        }
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
