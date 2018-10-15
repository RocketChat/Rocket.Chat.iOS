//
//  MessageHeaderCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

class MessageHeaderCell: UICollectionViewCell, ChatCell {
    var adjustedHorizontalInsets: CGFloat = 0
    var viewModel: AnyChatItem?

    lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()

        avatarView.layer.cornerRadius = 4
        avatarView.layer.masksToBounds = true

        return avatarView
    }()

    func configure() {}

    func configure(with avatarView: AvatarView, date: UILabel, and username: UILabel) {
        guard
            let viewModel = viewModel?.base as? MessageHeaderChatItem,
            let user = viewModel.user
        else {
            return
        }

        date.text = viewModel.dateFormatted
        username.text = user.username
        avatarView.emoji = viewModel.emoji
        avatarView.user = user.managedObject

        if let avatar = viewModel.avatar {
            avatarView.avatarURL = URL(string: avatar)
        }
    }
}
