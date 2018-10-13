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

    func configure() {}

    func configure(with avatarView: AvatarView, date: UILabel, and username: UILabel) {
        guard let viewModel = viewModel?.base as? MessageHeaderChatItem else {
            return
        }

        date.text = viewModel.dateFormatted
        username.text = viewModel.user.username
        avatarView.emoji = viewModel.emoji.isEmpty ? nil : viewModel.emoji
        avatarView.user = viewModel.user.managedObject

        if !viewModel.avatar.isEmpty {
            avatarView.avatarURL = URL(string: viewModel.avatar)
        }
    }
}
