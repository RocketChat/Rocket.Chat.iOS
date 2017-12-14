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
            case .online: viewStatus.backgroundColor = .RCOnline()
            case .busy: viewStatus.backgroundColor = .RCBusy()
            case .away: viewStatus.backgroundColor = .RCAway()
            case .offline: viewStatus.backgroundColor = .RCInvisible()
            }
        }
    }

    override var intrinsicContentSize: CGSize {
        if #available(iOS 11.0, *) {
            return UILayoutFittingExpandedSize
        }

        return UILayoutFittingCompressedSize
    }

}
