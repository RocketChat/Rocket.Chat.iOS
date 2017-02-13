//
//  SubscriptionUserStatusView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 13/02/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class SubscriptionUserStatusView: BaseView {

    @IBOutlet weak var imageViewSettings: UIImageView! {
        didSet {
            imageViewSettings.image = imageViewSettings.image?.imageWithTint(.RCLightBlue())
        }
    }

    @IBOutlet weak var imageViewLogout: UIImageView! {
        didSet {
            imageViewLogout.image = imageViewLogout.image?.imageWithTint(.RCLightBlue())
        }
    }

}
