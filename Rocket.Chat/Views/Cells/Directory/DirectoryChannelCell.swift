//
//  DirectoryChannelCell.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 14/03/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import UIKit

final class DirectoryChannelCell: UITableViewCell {

    static let identifier = String(describing: DirectoryChannelCell.self)

    var channel: UnmanagedSubscription? {
        didSet {
            if channel != nil {
                updateChannelInformation()
            }
        }
    }

    @IBOutlet weak var imageViewAvatar: UIImageView!
    @IBOutlet weak var imageViewIcon: UIImageView!

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelTopic: UILabel!
    @IBOutlet weak var labelUsers: UILabel!

    override func prepareForReuse() {
        super.prepareForReuse()

        channel = nil
        imageViewAvatar.image = nil
        imageViewIcon.image = nil
        labelName.text = nil
        labelTopic.text = nil
        labelUsers.text = nil
    }

    // MARK: Data Management

    func updateChannelInformation() {
        guard let channel = channel else { return }

        if let avatarURL = Subscription.avatarURL(for: channel.name) {
            ImageManager.loadImage(with: avatarURL, into: imageViewAvatar) { _, _ in }
        }

        if channel.type == .channel {
            imageViewIcon.image = UIImage(named: "Cell Subscription Hashtag")
        } else {
            imageViewIcon.image = UIImage(named: "Cell Subscription Lock")
        }

        labelName.text = channel.name

        if let topic = channel.roomTopic, !topic.isEmpty {
            labelTopic.text = topic
        } else {
            labelTopic.text = localized("chat.info.item.no_topic")
        }

        if channel.usersCount == 1 {
            labelUsers.text = localized("directory.users.1_user")
        } else {
            labelUsers.text = String(format: localized("directory.users.x_users"), channel.usersCount.humanized())
        }
    }

}

// MARK: Themeable

extension DirectoryChannelCell {

    override func applyTheme() {
        super.applyTheme()

        guard let theme = theme else { return }

        labelName.textColor = theme.bodyText
        labelTopic.textColor = theme.auxiliaryText
        labelUsers.textColor = theme.auxiliaryText
    }

}
