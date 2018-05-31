//
//  NotificationView.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 3/22/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class NotificationView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var bodyLabel: UILabel!

    @IBOutlet weak var grabber: UIView! {
        didSet {
            grabber.layer.cornerRadius = grabber.frame.height / 2
        }
    }

    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarViewContainer.layer.cornerRadius = 4
            if let avatarView = AvatarView.instantiateFromNib() {
                avatarView.frame = avatarViewContainer.bounds
                avatarViewContainer.addSubview(avatarView)
                self.avatarView = avatarView
            }
        }
    }

    weak var avatarView: AvatarView! {
        didSet {
            avatarView.layer.cornerRadius = 2
            avatarView.layer.masksToBounds = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.clipsToBounds = true
    }

    func displayNotification(title: String, body: String, username: String) {
        titleLabel.text = title
        bodyLabel.text = body
        avatarView.username = username
    }

}
