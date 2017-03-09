//
//  ChatTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatTitleView: UIView {

    let iconColor = UIColor(rgb: 0x999999, alphaVal: 1)

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imageArrowDown: UIImageView! {
        didSet {
            imageArrowDown.image = imageArrowDown.image?.imageWithTint(iconColor)
        }
    }

    var subscription: Subscription! {
        didSet {
            labelTitle.text = subscription.name

            switch subscription.type {
            case .channel:
                icon.image = UIImage(named: "Hashtag")?.imageWithTint(iconColor)
                break
            case .directMessage:
                var color = iconColor

                if let user = subscription.directMessageUser {
                    color = { _ -> UIColor in
                        switch user.status {
                        case .online: return .RCOnline()
                        case .offline: return iconColor
                        case .away: return .RCAway()
                        case .busy: return .RCBusy()
                        }
                    }()
                }

                icon.image = UIImage(named: "Mention")?.imageWithTint(color)
                break
            case .group:
                icon.image = UIImage(named: "Lock")?.imageWithTint(iconColor)
                break
            }
        }
    }

}
