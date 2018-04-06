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
            avatarView.layer.cornerRadius = 4
            avatarView.layer.masksToBounds = true
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
//        self.layer.borderWidth = 0.5
//        self.layer.borderColor = UIColor.black.withAlphaComponent(0.1).cgColor
        self.layer.cornerRadius = 12
        self.clipsToBounds = true
    }

    func displayNotification(title: String, body: String, user: User) {
        titleLabel.text = title
        bodyLabel.text = body
        avatarView.user = user
    }

}
