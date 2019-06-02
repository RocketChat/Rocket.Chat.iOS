//
//  ChatTextCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

// swiftlint:disable file_length
protocol ChatMessageCellProtocol: ChatMessageURLViewProtocol, ChatMessageVideoViewProtocol, ChatMessageImageViewProtocol, ChatMessageTextViewProtocol, ChatMessageActionButtonsViewProtocol {
    func openURL(url: URL)

    func openThread(identifier: String)

    func handleLongPressMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer)
    func handleUsernameTapMessageCell(_ message: Message, view: UIView, recognizer: UIGestureRecognizer)
    func handleLongPress(reactionListView: ReactionListView, reactionView: ReactionView)
    func handleReadReceiptPress(_ message: Message, source: (UIView, CGRect))
    func handleReviewRequest()
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
            if oldValue != nil && oldValue == message {
                return
            }

            updateMessage()
        }
    }

    var settings: AuthSettings? {
        return AuthManager.isAuthenticated()?.settings
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
        avatarView.layer.cornerRadius = 4
        avatarView.layer.masksToBounds = true
        return avatarView
    }()

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelText: RCTextView!

    @IBOutlet weak var statusView: UIImageView!

    @IBOutlet weak var mediaViews: UIStackView!
    @IBOutlet weak var mediaViewsHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var reactionsListView: ReactionListView! {
        didSet {
            reactionsListView.reactionTapRecognized = { view, sender in
                let client = API.current()?.client(MessagesClient.self)
                client?.reactMessage(self.message, emoji: view.model.emoji)

                if self.isAddingReaction(emoji: view.model.emoji) {
                    UserReviewManager.shared.requestReview()
                }
            }

            reactionsListView.reactionLongPressRecognized = { view, sender in
                self.delegate?.handleLongPress(reactionListView: self.reactionsListView, reactionView: view)
            }
        }
    }

    private func isAddingReaction(emoji tappedEmoji: String) -> Bool {
        guard let currentUser = AuthManager.currentUser()?.username else {
            return false
        }

        if Array(message.reactions).first(where: { $0.emoji == tappedEmoji && Array($0.usernames).contains(currentUser) }) != nil {
            return false
        }

        return true
    }

    @IBOutlet weak var reactionsListViewConstraint: NSLayoutConstraint!

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

    // MARK: Read Receipt

    @IBOutlet weak var readReceiptButton: UIButton!
    @IBOutlet weak var readReceiptConstraint: NSLayoutConstraint!

    func updateReadReceipt() {
        guard let settings = settings else {
            return
        }

        if settings.messageReadReceiptEnabled {
            readReceiptConstraint.constant = 12.0
        } else {
            readReceiptConstraint.constant = 0.0
        }

        let image = UIImage(named: "Check")?.imageWithTint(message.unread ? #colorLiteral(red: 0.6, green: 0.6, blue: 0.6, alpha: 1) : #colorLiteral(red: 0.1137254902, green: 0.4549019608, blue: 0.9607843137, alpha: 1), alpha: 0.0)
        readReceiptButton.setImage(image, for: .normal)
    }

    @IBAction func readReceiptPressed(_ sender: UIButton) {
        guard
            let settings = settings,
            settings.messageReadReceiptStoreUsers
        else {
            return
        }

        delegate?.handleReadReceiptPress(message, source: (readReceiptButton, readReceiptButton.frame))
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        labelUsername.text = ""
        labelText.message = nil
        labelDate.text = ""

        sequential = false
        message = nil

        avatarView.prepareForReuse()

        for view in mediaViews.arrangedSubviews {
            mediaViews.removeArrangedSubview(view)
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

    func insertButtonActions() -> CGFloat {
        var addedHeight = CGFloat(0)

        if message.isBroadcastReplyAvailable() {
            if let view = ChatMessageActionButtonsView.instantiateFromNib() {
                view.message = message
                view.delegate = delegate

                mediaViews.addArrangedSubview(view)
                addedHeight += ChatMessageActionButtonsView.defaultHeight
            }
        }

        return addedHeight
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
            case .textAttachment: mediaViewHeight += insertTextAttachment(attachment)
            case .image: mediaViewHeight += insertImageAttachment(attachment)
            case .video: mediaViewHeight += insertVideoAttachment(attachment)
            case .audio: mediaViewHeight += insertAudioAttachment(attachment)
            default: return
            }
        }

        mediaViewHeight += insertButtonActions()
        mediaViewsHeightConstraint.constant = CGFloat(mediaViewHeight)
    }

    fileprivate func updateMessageHeader() {
        if let createdAt = message.createdAt {
            labelDate.text = RCDateFormatter.time(createdAt)
        }

        avatarView.emoji = message.emoji
        avatarView.username = message.user?.username

        if let avatar = message.avatar {
            avatarView.avatarURL = URL(string: avatar)
        }

        labelUsername.text = message.user?.displayName() ?? "Unknown"

        if message.alias.count > 0 {
            labelUsername.text = message.alias
        }
    }

    fileprivate func updateMessageContent(force: Bool = false) {
        guard let unmanagedMessage = message.unmanaged else {
            return
        }

        if let text = force ? MessageTextCacheManager.shared.update(for: unmanagedMessage, with: theme) : MessageTextCacheManager.shared.message(for: unmanagedMessage, with: theme) {
            if message.temporary {
                text.setFontColor(MessageTextFontAttributes.systemFontColor(for: theme))
            } else if message.failed {
                text.setFontColor(MessageTextFontAttributes.failedFontColor(for: theme))
            }

            labelText.message = text
        }
    }

    fileprivate func updateMessage() {
        guard let message = message else { return }

        if message.failed {
            statusView.isHidden = false
            statusView.image = UIImage(named: "Exclamation")?.withRenderingMode(.alwaysTemplate)
            statusView.tintColor = .red
        } else {
            statusView.isHidden = true
        }

        if !sequential {
            updateMessageHeader()
        }

        updateMessageContent()
        insertGesturesIfNeeded()
        insertAttachments()
        updateReactions()
        updateReadReceipt()
    }

    @objc func handleLongPressMessageCell(recognizer: UIGestureRecognizer) {
        delegate?.handleLongPressMessageCell(message, view: contentView, recognizer: recognizer)
    }

    @objc func handleUsernameTapGestureCell(recognizer: UIGestureRecognizer) {
        delegate?.handleUsernameTapMessageCell(message, view: labelUsername, recognizer: recognizer)
    }
}

extension ChatMessageCell: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}

// MARK: Height calculation

extension ChatMessageCell {

    // swiftlint:disable cyclomatic_complexity
    static func cellMediaHeightFor(message: Message, width: CGFloat, sequential: Bool = true) -> CGFloat {
        guard let unmanagedMessage = message.unmanaged else {
            return 0
        }

        let attributedString = MessageTextCacheManager.shared.message(for: unmanagedMessage, with: nil)

        var total = (CGFloat)(sequential ? 8 : 29) + (message.reactions.count > 0 ? 40 : 0)
        if attributedString?.string ?? "" != "" {
            total += (attributedString?.heightForView(withWidth: width - 62) ?? 0)
        }

        if message.isBroadcastReplyAvailable() {
            total += ChatMessageActionButtonsView.defaultHeight
        }

        for url in message.urls {
            guard url.isValid() else { continue }
            total += ChatMessageURLView.defaultHeight
        }

        for attachment in message.attachments {
            let type = attachment.type

            if type == .textAttachment {
                total += ChatMessageTextView.heightFor(with: width, collapsed: attachment.collapsed, text: attachment.text, isFile: attachment.isFile)
            }

            if type == .image {
                total += ChatMessageImageView.heightFor(with: width, description: attachment.descriptionText)
            }

            if type == .video {
                total += ChatMessageVideoView.heightFor(with: width, description: attachment.descriptionText)
            }

            if type == .audio {
                total += ChatMessageAudioView.heightFor(with: width, description: attachment.descriptionText)
            }

            if !attachment.collapsed {
                attachment.fields.forEach {
                    total += ChatMessageTextView.heightFor(with: width, collapsed: false, text: $0.value)
                }
            }
        }

        return total
    }
}

// MARK: Reactions

extension ChatMessageCell {
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
}

// MARK: Insert attachments

extension ChatMessageCell {
    private func insertTextAttachment(_ attachment: Attachment) -> CGFloat {
        guard let view = ChatMessageTextView.instantiateFromNib() else { return 0 }
        view.viewModel = ChatMessageTextViewModel(withAttachment: attachment)
        view.delegate = delegate
        view.translatesAutoresizingMaskIntoConstraints = false

        mediaViews.addArrangedSubview(view)

        let availableWidth = frame.size.width
        var attachmentHeight = ChatMessageTextView.heightFor(with: availableWidth, collapsed: attachment.collapsed, text: attachment.text, isFile: attachment.isFile)

        if !attachment.collapsed {
            attachment.fields.forEach {
                guard let view = ChatMessageTextView.instantiateFromNib() else { return }
                view.viewModel = ChatMessageAttachmentFieldViewModel(withAttachment: attachment, andAttachmentField: $0)
                mediaViews.addArrangedSubview(view)
                attachmentHeight += ChatMessageTextView.heightFor(with: availableWidth, collapsed: false, text: $0.value)
            }
        }

        return attachmentHeight
    }

    private func insertImageAttachment(_ attachment: Attachment) -> CGFloat {
        guard let view = ChatMessageImageView.instantiateFromNib() else { return 0 }
        view.attachment = attachment
        view.delegate = delegate
        view.translatesAutoresizingMaskIntoConstraints = false
        mediaViews.addArrangedSubview(view)

        let availableWidth = frame.size.width
        return ChatMessageImageView.heightFor(with: availableWidth, description: attachment.descriptionText)
    }

    private func insertVideoAttachment(_ attachment: Attachment) -> CGFloat {
        guard let view = ChatMessageVideoView.instantiateFromNib() else { return 0 }
        view.attachment = attachment
        view.delegate = delegate
        view.translatesAutoresizingMaskIntoConstraints = false
        mediaViews.addArrangedSubview(view)

        let availableWidth = frame.size.width
        return ChatMessageImageView.heightFor(with: availableWidth, description: attachment.descriptionText)
    }

    private func insertAudioAttachment(_ attachment: Attachment) -> CGFloat {
        guard let view = ChatMessageAudioView.instantiateFromNib() else { return 0 }
        view.attachment = attachment
        view.translatesAutoresizingMaskIntoConstraints = false
        mediaViews.addArrangedSubview(view)

        let availableWidth = frame.size.width
        return ChatMessageImageView.heightFor(with: availableWidth, description: attachment.descriptionText)
    }
}

// MARK: Themeable

extension ChatMessageCell {
    override func applyTheme() {
        super.applyTheme()
        guard let theme = theme else { return }
        labelDate.textColor = theme.auxiliaryText
        labelUsername.textColor = theme.titleText
        updateMessageContent(force: true)
    }
}
