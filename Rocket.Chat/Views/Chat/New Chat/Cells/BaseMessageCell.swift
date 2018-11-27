//
//  MessageHeaderCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

class BaseMessageCell: UICollectionViewCell, ChatCell {
    var messageWidth: CGFloat = 0
    var viewModel: AnyChatItem?
    var messageSection: MessageSection?

    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var usernameTapGesture: UITapGestureRecognizer?
    weak var avatarTapGesture: UITapGestureRecognizer?

    lazy var avatarView: AvatarView = {
        let avatarView = AvatarView()

        avatarView.layer.cornerRadius = 4
        avatarView.layer.masksToBounds = true

        return avatarView
    }()

    var settings: AuthSettings? {
        return AuthManager.isAuthenticated()?.settings
    }

    func configure(completeRendering: Bool) {}

    func configure(with avatarView: AvatarView, date: UILabel, and username: UILabel, completeRendering: Bool) {
        guard
            let viewModel = viewModel?.base as? BaseMessageChatItem,
            let user = viewModel.user
        else {
            return
        }

        date.text = viewModel.dateFormatted
        username.text = viewModel.alias ?? user.username

        if completeRendering {
            avatarView.emoji = viewModel.emoji
            avatarView.username = user.username

            if let avatar = viewModel.avatar {
                avatarView.avatarURL = URL(string: avatar)
            } else {
                avatarView.avatarURL = user.avatarURL
            }
        }
    }

    func configure(readReceipt button: UIButton) {
        guard
            let viewModel = viewModel?.base as? BaseMessageChatItem,
            let settings = settings
        else {
            return
        }

        if settings.messageReadReceiptEnabled {
            button.isHidden = false
        } else {
            button.isHidden = true
            button.changeWidth(to: 0)
            button.changeLeading(to: 0)

            let image = viewModel.isUnread ? UIImage(named: "Unread") : UIImage(named: "Read")
            button.setImage(image, for: .normal)
        }
    }

    func insertGesturesIfNeeded(with username: UILabel?) {
        if longPressGesture == nil {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressMessageCell(recognizer:)))
            gesture.minimumPressDuration = 0.325
            gesture.delegate = self
            addGestureRecognizer(gesture)

            longPressGesture = gesture
        }

        if usernameTapGesture == nil && username != nil {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTapGestureCell(recognizer:)))
            gesture.delegate = self
            username?.addGestureRecognizer(gesture)

            usernameTapGesture = gesture
        }

        if avatarTapGesture == nil {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTapGestureCell(recognizer:)))
            gesture.delegate = self
            avatarView.addGestureRecognizer(gesture)

            avatarTapGesture = gesture
        }
    }

    @objc func handleLongPressMessageCell(recognizer: UIGestureRecognizer) { }

    @objc func handleUsernameTapGestureCell(recognizer: UIGestureRecognizer) { }

}

// MARK: UIGestureRecognizerDelegate

extension BaseMessageCell: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}
