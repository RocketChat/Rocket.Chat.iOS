//
//  SubscriptionsTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 9/24/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionsTitleView: UIView {

    weak var avatarView: AvatarView?
    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarViewContainer.layer.masksToBounds = true
            avatarViewContainer.layer.cornerRadius = avatarViewContainer.frame.width / 2

            if let avatarView = AvatarView.instantiateFromNib() {
                avatarView.frame = CGRect(
                    x: 0,
                    y: 0,
                    width: avatarViewContainer.frame.width,
                    height: avatarViewContainer.frame.height
                )

                avatarViewContainer.addSubview(avatarView)
                self.avatarView = avatarView
            }
        }
    }

    @IBOutlet weak var labelUser: UILabel!
    @IBOutlet weak var viewStatus: UIView!

    var user: User? {
        didSet {
            guard let user = user else { return }

            labelUser.text = user.displayName()
            avatarView?.user = user

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
