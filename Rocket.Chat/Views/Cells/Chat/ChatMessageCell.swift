//
//  ChatTextCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatMessageCellProtocol: ChatMessageURLViewProtocol, ChatMessageVideoViewProtocol, ChatMessageImageViewProtocol, ChatMessageTextViewProtocol {
    func openURL(url: URL)
    func handleLongPressMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer)
    func handleUsernameTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer)
    func handleLongPress(reactionListView: ReactionListView, reactionView: ReactionView)
}

final class ChatMessageCell: UICollectionViewCell {

    static let minimumHeight = CGFloat(55)
    static let identifier = "ChatMessageCell"

    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var usernameTapGesture: UITapGestureRecognizer?
    weak var avatarTapGesture: UITapGestureRecognizer?
    weak var delegate: ChatMessageCellProtocol? {
        didSet {
            labelText.delegate = delegate
        }
    }

    var message: Message! {
        didSet {
            if oldValue != nil && oldValue.identifier == message?.identifier {
                if oldValue.updatedAt?.timeIntervalSince1970 == message.updatedAt?.timeIntervalSince1970 {
                    Log.debug("message is cached")
                    return
                }
            }

            updateMessage()
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
            avatarView.layer.cornerRadius = 4
            avatarView.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelText: RCTextView!

    @IBOutlet weak var mediaViews: UIStackView!
    @IBOutlet weak var mediaViewsHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var reactionsListView: ReactionListView! {
        didSet {
            reactionsListView.reactionTapRecognized = { view, sender in
                MessageManager.react(self.message, emoji: view.model.emoji, completion: { _ in })
            }

            reactionsListView.reactionLongPressRecognized = { view, sender in
                self.delegate?.handleLongPress(reactionListView: self.reactionsListView, reactionView: view)
            }
        }
    }
    @IBOutlet weak var reactionsListViewConstraint: NSLayoutConstraint!

    static func cellMediaHeightFor(message: Message, width: CGFloat, sequential: Bool = true) -> CGFloat {
        let fullWidth = width
        let attributedString = MessageTextCacheManager.shared.message(for: message)

        var total = (CGFloat)(sequential ? 8 : 29) + (message.reactions.count > 0 ? 40 : 0)
        if attributedString?.string ?? "" != "" {
            total += (attributedString?.heightForView(withWidth: fullWidth - 55) ?? 0)
        }

        for url in message.urls {
            guard url.isValid() else { continue }
            total += ChatMessageURLView.defaultHeight
        }

        for attachment in message.attachments {
            let type = attachment.type

            if type == .textAttachment {
                total += ChatMessageTextView.heightFor(collapsed: attachment.collapsed, withText: attachment.text)
            }

            if type == .image {
                total += ChatMessageImageView.heightFor(withText: attachment.descriptionText)
            }

            if type == .video {
                total += ChatMessageVideoView.heightFor(withText: attachment.descriptionText)
            }

            if type == .audio {
                total += ChatMessageAudioView.heightFor(withText: attachment.descriptionText)
            }
        }

        return total
    }

    // MARK: Sequential
    @IBOutlet weak var labelUsernameHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var labelDateHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var avatarContainerHeightConstraint: NSLayoutConstraint!

    var sequential: Bool = false {
        didSet {
            avatarContainerHeightConstraint.constant = sequential ? 0 : 35
            labelUsernameHeightConstraint.constant = sequential ? 0 : 21
            labelDateHeightConstraint.constant = sequential ? 0 : 21
        }
    }

    override func prepareForReuse() {
        labelUsername.text = ""
        labelText.message = nil
        labelDate.text = ""
        sequential = false
        message = nil

        avatarView.prepareForReuse()

        for view in mediaViews.arrangedSubviews {
            view.removeFromSuperview()
        }
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
            labelUsername.addGestureRecognizer(gesture)

            usernameTapGesture = gesture
        }

        if avatarTapGesture == nil {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleUsernameTapGestureCell(recognizer:)))
            gesture.delegate = self
            avatarView.addGestureRecognizer(gesture)

            avatarTapGesture = gesture
        }
    }

    func insertURLs() -> CGFloat {
        var addedHeight = CGFloat(0)
        message.urls.forEach { url in
            guard url.isValid() else { return }
            if let view = ChatMessageURLView.instantiateFromNib() {
                view.url = url
                view.delegate = delegate

                mediaViews.addArrangedSubview(view)
                addedHeight += ChatMessageURLView.defaultHeight
            }
        }
        return addedHeight
    }

    func insertAttachments() {
        var mediaViewHeight = CGFloat(0)

        mediaViewHeight += insertURLs()

        message.attachments.forEach { attachment in
            let type = attachment.type

            switch type {
            case .textAttachment:
                if let view = ChatMessageTextView.instantiateFromNib() {
                    view.viewModel = ChatMessageTextViewModel(withAttachment: attachment)
                    view.delegate = delegate
                    view.translatesAutoresizingMaskIntoConstraints = false

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight += ChatMessageTextView.heightFor(collapsed: attachment.collapsed, withText: attachment.text)
                }

            case .image:
                if let view = ChatMessageImageView.instantiateFromNib() {
                    view.attachment = attachment
                    view.delegate = delegate
                    view.translatesAutoresizingMaskIntoConstraints = false

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight += ChatMessageImageView.heightFor(withText: attachment.descriptionText)
                }

            case .video:
                if let view = ChatMessageVideoView.instantiateFromNib() {
                    view.attachment = attachment
                    view.delegate = delegate
                    view.translatesAutoresizingMaskIntoConstraints = false

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight += ChatMessageVideoView.heightFor(withText: attachment.descriptionText)
                }

            case .audio:
                if let view = ChatMessageAudioView.instantiateFromNib() {
                    view.attachment = attachment
                    view.translatesAutoresizingMaskIntoConstraints = false

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight += ChatMessageAudioView.heightFor(withText: attachment.descriptionText)
                }

            default:
                return
            }
        }

        mediaViewsHeightConstraint.constant = CGFloat(mediaViewHeight)
    }

    fileprivate func updateMessageHeader() {
        if let createdAt = message.createdAt {
            labelDate.text = RCDateFormatter.time(createdAt)
        }

        avatarView.user = message.user
        avatarView.emoji = message.emoji

        if let avatar = message.avatar {
            avatarView.avatarURL = URL(string: avatar)
        }

        if message.alias.count > 0 {
            labelUsername.text = message.alias
        } else {
            labelUsername.text = message.user?.displayName() ?? "Unknown"
        }
    }

    fileprivate func updateMessageContent() {
        if let text = MessageTextCacheManager.shared.message(for: message) {
            if message.temporary {
                text.setFontColor(MessageTextFontAttributes.systemFontColor)
            }

            labelText.message = text
        }
    }

    fileprivate func updateReactions() {
        let username = AuthManager.currentUser()?.username

        let models = Array(message.reactions.map { reaction -> ReactionViewModel in
            let highlight: Bool
            if let username = username {
                highlight = reaction.usernames.contains(username)
            } else {
                highlight = false
            }

            let emoji = reaction.emoji ?? "?"
            let imageUrl = CustomEmoji.withShortname(emoji)?.imageUrl()

            return ReactionViewModel(
                emoji: emoji,
                imageUrl: imageUrl,
                count: reaction.usernames.count.description,
                highlight: highlight,
                reactors: Array(reaction.usernames)
            )
        })

        reactionsListView.model = ReactionListViewModel(reactionViewModels: models)

        if message.reactions.count > 0 {
            reactionsListView.isHidden = false
            reactionsListViewConstraint.constant = 40
        } else {
            reactionsListView.isHidden = true
            reactionsListViewConstraint.constant = 0
        }
    }

    fileprivate func updateMessage() {
        guard
            delegate != nil,
            message != nil
        else {
            return
        }

        if !sequential {
            updateMessageHeader()
        }

        updateMessageContent()
        insertGesturesIfNeeded()
        insertAttachments()
        updateReactions()
    }

    @objc func handleLongPressMessageCell(recognizer: UIGestureRecognizer) {
        delegate?.handleLongPressMessageCell(message, view: contentView, recognizer: recognizer)
    }

    @objc func handleUsernameTapGestureCell(recognizer: UIGestureRecognizer) {
        delegate?.handleUsernameTapMessageCell(message, view: contentView, recognizer: recognizer)
    }

}

extension ChatMessageCell: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}

// MARK: Accessibility

extension ChatMessageCell {

    override func awakeFromNib() {
        isAccessibilityElement = true
    }

    override var accessibilityIdentifier: String? {
        get { return "message" }
        set { }
    }

    override var accessibilityLabel: String? {
        get { return message?.accessibilityLabel }
        set { }
    }

    override var accessibilityValue: String? {
        get { return message?.accessibilityValue }
        set { }
    }

    override var accessibilityHint: String? {
        get { return message?.accessibilityHint }
        set { }
    }

}
