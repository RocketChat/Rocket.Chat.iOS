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

}
