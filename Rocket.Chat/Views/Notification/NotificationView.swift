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
    @IBOutlet weak var backgroundBlurView: UIVisualEffectView!

    @IBOutlet weak var grabber: UIView! {
        didSet {
            grabber.layer.cornerRadius = grabber.frame.height / 2
        }
    }

    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
            avatarViewContainer.layer.cornerRadius = 4
            avatarView.frame = avatarViewContainer.bounds
            avatarViewContainer.addSubview(avatarView)
        }
    }

    lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()
        avatarView.layer.cornerRadius = 2
        avatarView.layer.masksToBounds = true
        return avatarView
    }()

    func displayNotification(title: String, body: String, username: String) {
        titleLabel.text = title
        bodyLabel.text = body
        avatarView.username = username
    }

    private func applyShadow(color: UIColor = .black) {
        layer.shadowColor = color.cgColor
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 0.5
        layer.shadowOffset = CGSize(width: 0, height: 0)
    }
}

extension NotificationView {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        bodyLabel.textColor = theme.bodyText
        titleLabel.textColor = theme.titleText
        grabber.backgroundColor = theme.titleText.withAlphaComponent(0.18)
        applyShadow(color: theme.titleText)
    }
}
