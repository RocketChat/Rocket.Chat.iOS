//
//  ChatTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

final class ChatTitleView: UIView {

    @IBOutlet weak var icon: UIImageView!
    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.textColor = .RCDarkGray()
        }
    }

    @IBOutlet weak var imageArrowDown: UIImageView! {
        didSet {
            imageArrowDown.image = imageArrowDown.image?.imageWithTint(.RCGray())
        }
    }

    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }

    var subscription: Subscription? {
        didSet {
            guard
                let subscription = subscription,
                !subscription.isInvalidated
            else {
                return
            }

            labelTitle.text = subscription.displayName()

            switch subscription.type {
            case .channel:
                icon.image = UIImage(named: "Hashtag")?.imageWithTint(.RCGray())
            case .directMessage:
                var color = UIColor.RCGray()

                if let user = subscription.directMessageUser {
                    color = { _ -> UIColor in
                        switch user.status {
                        case .online: return .RCOnline()
                        case .offline: return .RCGray()
                        case .away: return .RCAway()
                        case .busy: return .RCBusy()
                        }
                    }(())
                }

                icon.image = UIImage(named: "Mention")?.imageWithTint(color)
            case .group:
                icon.image = UIImage(named: "Lock")?.imageWithTint(.RCGray())
            }
        }
    }

}
