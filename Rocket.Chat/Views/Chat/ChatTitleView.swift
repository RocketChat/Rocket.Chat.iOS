//
//  ChatTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatTitleView: BaseView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!

    internal let iconColorOffline = UIColor(rgb: 0x9AB1BF, alphaVal: 1)
    internal let iconColorOnline = UIColor(rgb: 0x35AC19, alphaVal: 1)
    internal let iconColorAway = UIColor(rgb: 0xFCB316, alphaVal: 1)
    internal let iconColorBusy = UIColor(rgb: 0xD30230, alphaVal: 1)

    var subscription: Subscription! {
        didSet {
            labelTitle.text = subscription.name

            switch subscription.type {
            case .channel:
                icon.image = UIImage(named: "Hashtag")?.imageWithTint(iconColorOffline)
                break
            case .directMessage:
                var color = iconColorOffline

                if let user = subscription.directMessageUser {
                    color = { _ -> UIColor in
                        switch user.status {
                        case .online: return self.iconColorOnline
                        case .offline: return self.iconColorOffline
                        case .away: return self.iconColorAway
                        case .busy: return self.iconColorBusy
                        }
                    }()
                }

                icon.image = UIImage(named: "Mention")?.imageWithTint(color)
                break
            case .group:
                icon.image = UIImage(named: "Lock")?.imageWithTint(iconColorOffline)
                break
            }
        }
    }
    // MARK: Replaceable

    override func isReplaceable() -> Bool {
        return true
    }
}
