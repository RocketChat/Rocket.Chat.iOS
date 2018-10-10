//
//  BasicMessageCell.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 23/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit
import RocketChatViewController

final class BasicMessageCell: UICollectionViewCell, ChatCell, SizingCell {
    static let identifier = String(describing: BasicMessageCell.self)

    // MARK: SizingCell

    static let sizingCell: UICollectionViewCell & ChatCell = {
        guard let cell = BasicMessageCell.instantiateFromNib() else {
            return BasicMessageCell()
        }

        return cell
    }()

    @IBOutlet weak var avatarContainerView: UIView! {
        didSet {
            avatarContainerView.layer.cornerRadius = 4
            avatarView.frame = avatarContainerView.bounds
            avatarContainerView.addSubview(avatarView)
        }
    }

    let avatarView: AvatarView = {
        let avatarView = AvatarView()

        avatarView.layer.cornerRadius = 4
        avatarView.layer.masksToBounds = true

        return avatarView
    }()

    @IBOutlet weak var username: UILabel!
    @IBOutlet weak var date: UILabel!
    @IBOutlet weak var text: RCTextView!

    @IBOutlet weak var textHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var textLeadingConstraint: NSLayoutConstraint!
    @IBOutlet weak var textTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarLeadingConstraint: NSLayoutConstraint!
    var textHorizontalMargins: CGFloat {
        return
            textLeadingConstraint.constant +
            textTrailingConstraint.constant +
            avatarWidthConstraint.constant +
            avatarLeadingConstraint.constant +
            adjustedHorizontalInsets
    }

    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var usernameTapGesture: UITapGestureRecognizer?
    weak var avatarTapGesture: UITapGestureRecognizer?
    weak var delegate: ChatMessageCellProtocol? {
        didSet {
            text.delegate = delegate
        }
    }

    var viewModel: AnyChatItem?
    var adjustedHorizontalInsets: CGFloat = 0
    var initialTextHeightConstant: CGFloat = 0
    var contentViewWidthConstraint: NSLayoutConstraint!

    override func awakeFromNib() {
        super.awakeFromNib()

        initialTextHeightConstant = textHeightConstraint.constant
        insertGesturesIfNeeded()
    }

    func configure() {
        guard let viewModel = viewModel?.base as? BasicMessageChatItem else {
            return
        }

        let createdAt = viewModel.message.createdAt
        date.text = RCDateFormatter.time(createdAt)

        username.text = viewModel.user.username
        updateText()
    }

    func updateText(force: Bool = false) {
        guard let viewModel = viewModel?.base as? BasicMessageChatItem else {
            return
        }

        avatarView.emoji = viewModel.message.emoji
        avatarView.user = viewModel.message.user?.managedObject

        if let avatar = viewModel.message.avatar {
            avatarView.avatarURL = URL(string: avatar)
        }

        if let message = force ? MessageTextCacheManager.shared.update(for: viewModel.message.managedObject, with: theme) : MessageTextCacheManager.shared.message(for: viewModel.message.managedObject, with: theme) {
            if viewModel.message.temporary {
                message.setFontColor(MessageTextFontAttributes.systemFontColor(for: theme))
            } else if viewModel.message.failed {
                message.setFontColor(MessageTextFontAttributes.failedFontColor(for: theme))
            }

            text.message = message

            // FA NOTE: Using UIScreen.main bounds is fine because we are not using
            // section insets, but in the future we can create a mechanism that
            // discounts the UICollectionView's section insets from the main screen's bounds
            let screenWidth = UIScreen.main.bounds.width
            let maxSize = CGSize(
                width: screenWidth - textHorizontalMargins,
                height: .greatestFiniteMagnitude
            )

            textHeightConstraint.constant = text.textView.sizeThatFits(
                maxSize
            ).height
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        username.text = ""
        date.text = ""
        text.message = nil
        avatarView.prepareForReuse()
        textHeightConstraint.constant = initialTextHeightConstant
    }

    func insertGesturesIfNeeded() {
        if longPressGesture == nil {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressMessageCell(recognizer:)))
            gesture.minimumPressDuration = 0.325
            gesture.delegate = self
            addGestureRecognizer(gesture)

            longPressGesture = gesture
        }

        if usernameTapGesture == nil {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTapGestureCell(recognizer:)))
            gesture.delegate = self
            username.addGestureRecognizer(gesture)

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
        guard let viewModel = viewModel?.base as? BasicMessageChatItem else {
            return
        }

        delegate?.handleLongPressMessageCell(viewModel.message.managedObject, view: contentView, recognizer: recognizer)
    }

    @objc func handleUsernameTapGestureCell(recognizer: UIGestureRecognizer) {
        guard let viewModel = viewModel?.base as? BasicMessageChatItem else {
            return
        }

        delegate?.handleUsernameTapMessageCell(viewModel.message.managedObject, view: username, recognizer: recognizer)
    }
}

// MARK: UIGestureRecognizerDelegate

extension BasicMessageCell: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }
}

// MARK: Theming

extension BasicMessageCell {

    override func applyTheme() {
        super.applyTheme()

        let theme = self.theme ?? .light
        date.textColor = theme.auxiliaryText
        username.textColor = theme.titleText
        updateText(force: true)
    }

}
