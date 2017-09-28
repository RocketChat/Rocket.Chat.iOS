//
//  SubscriptionsTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionsTitleView: UIView {

    @IBOutlet weak var labelUser: UILabel!
    @IBOutlet weak var viewStatus: UIView!

    var user: User? {
        didSet {
            guard let user = user else { return }

            labelUser.text = "@\(user.username ?? user.displayName())"

            switch user.status {
            case .online:
                viewStatus.backgroundColor = .RCOnline()
                break
            case .busy:
                viewStatus.backgroundColor = .RCBusy()
                break
            case .away:
                viewStatus.backgroundColor = .RCAway()
                break
            case .offline:
                viewStatus.backgroundColor = .RCInvisible()
                break
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        return UILayoutFittingExpandedSize
    }

}
