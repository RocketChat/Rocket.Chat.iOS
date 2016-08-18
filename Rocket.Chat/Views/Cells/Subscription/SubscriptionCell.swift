//
//  SubscriptionCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/4/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionCell: UITableViewCell {

    static let identifier = "CellSubscription"
    
    internal let iconColorOffline = UIColor(rgb: 0x9AB1BF, alphaVal: 1)
    internal let iconColorOnline = UIColor(rgb: 0x35AC19, alphaVal: 1)
    internal let iconColorAway = UIColor(rgb: 0xFCB316, alphaVal: 1)
    internal let iconColorBusy = UIColor(rgb: 0xD30230, alphaVal: 1)

    internal let labelSelectedTextColor = UIColor(rgb: 0xFFFFFF, alphaVal: 1)
    internal let labelReadTextColor = UIColor(rgb: 0x9AB1BF, alphaVal: 1)
    internal let labelUnreadTextColor = UIColor(rgb: 0xFFFFFF, alphaVal: 1)
    
    var subscription: Subscription! {
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
        updateIconImage()

        labelName.text = subscription.name
        
        if subscription.unread > 0 {
            labelName.font = UIFont.preferredFontForTextStyle(UIFontTextStyleHeadline)
            labelName.textColor = labelUnreadTextColor
        } else {
            labelName.font = UIFont.preferredFontForTextStyle(UIFontTextStyleBody)
            labelName.textColor = labelReadTextColor
        }
        
        labelUnread.alpha = subscription.unread > 0 ? 1 : 0
        labelUnread.text = "\(subscription.unread)"
    }
    
    func updateIconImage() {
        switch subscription.type {
        case .Channel:
            imageViewIcon.image = UIImage(named: "Hashtag")?.imageWithTint(iconColorOffline)
            break
        case .DirectMessage:
            var color = iconColorOffline

            if let user = subscription.directMessageUser {
                color = { _ -> UIColor in
                    switch user.status {
                    case .Online: return self.iconColorOnline
                    case .Offline: return self.iconColorOffline
                    case .Away: return self.iconColorAway
                    case .Busy: return self.iconColorBusy
                    }
                }()
            }

            imageViewIcon.image = UIImage(named: "Mention")?.imageWithTint(color)
            break
        case .Group:
            imageViewIcon.image = UIImage(named: "Lock")?.imageWithTint(iconColorOffline)
            break
        }
    }

}
