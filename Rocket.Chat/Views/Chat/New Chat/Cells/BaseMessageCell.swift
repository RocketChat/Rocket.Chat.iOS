//
//  MessageHeaderCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

class BaseMessageCell: UICollectionViewCell, BaseMessageCellProtocol, ChatCell {
    var messageWidth: CGFloat = 0
    var viewModel: AnyChatItem?
    var messageSection: MessageSection?

    weak var delegate: ChatMessageCellProtocol?

    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var usernameTapGesture: UITapGestureRecognizer?
    weak var avatarTapGesture: UITapGestureRecognizer?

    weak var usernameLabel: UILabel?
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

    func configure(
        with avatarView: AvatarView,
        date: UILabel?,
        status: UIImageView?,
        and username: UILabel?,
        completeRendering: Bool
    ) {
        guard
            let viewModel = viewModel?.base as? BaseMessageChatItem,
            let user = viewModel.user
        else {
            return
        }

        usernameLabel = username

        date?.text = viewModel.dateFormatted
        username?.text = viewModel.message?.alias ?? user.displayName

        if viewModel.message?.failed == true {
            status?.isHidden = false
            status?.image = UIImage(named: "Exclamation")?.withRenderingMode(.alwaysTemplate)
            status?.tintColor = .red
        } else {
            status?.isHidden = true
        }

        if completeRendering {
            avatarView.emoji = viewModel.message?.emoji
            avatarView.username = user.username

            if let avatar = viewModel.message?.avatar {
                avatarView.avatarURL = URL(string: avatar)
            } else {
                avatarView.avatarURL = user.avatarURL
            }
        }
    }

    func configure(readReceipt button: UIButton) {
        guard
            let viewModel = viewModel?.base as? BaseMessageChatItem,
            let settings = settings,
            let message = viewModel.message
        else {
            return
        }

        if settings.messageReadReceiptEnabled {
            button.isHidden = false

            let image = message.unread ? UIImage(named: "Unread") : UIImage(named: "Read")
            button.setImage(image, for: .normal)
        } else {
            button.isHidden = true
            button.changeWidth(to: 0)
            button.changeLeading(to: 0)
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

    @objc func handleLongPressMessageCell(recognizer: UIGestureRecognizer) {
        guard
            let viewModel = viewModel?.base as? BaseMessageChatItem,
            let managedObject = viewModel.message?.managedObject?.validated()
        else {
            return
        }

        delegate?.handleLongPressMessageCell(managedObject, view: contentView, recognizer: recognizer)
    }

    @objc func handleUsernameTapGestureCell(recognizer: UIGestureRecognizer) {
        guard
            let viewModel = viewModel?.base as? BaseMessageChatItem,
            let managedObject = viewModel.message?.managedObject?.validated(),
            let username = usernameLabel
        else {
            return
        }

        delegate?.handleUsernameTapMessageCell(managedObject, view: username, recognizer: recognizer)
    }

}

// MARK: UIGestureRecognizerDelegate

extension BaseMessageCell: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}
