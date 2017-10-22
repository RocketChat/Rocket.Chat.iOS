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
}

fileprivate enum Regex: String {
    case hashtag = "(?<!\\S)#[\\p{L}0-9_]+"
}

final class ChatMessageCell: UICollectionViewCell {

    static let minimumHeight = CGFloat(55)
    static let identifier = "ChatMessageCell"

    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var labelTextTapGesture: UITapGestureRecognizer?
    weak var delegate: ChatMessageCellProtocol?
    var rectsHighlight: [CGRect: String]?
    var message: Message! {
        didSet {
            updateMessage()
        }
    }

    @IBOutlet weak var avatarViewContainer: UIView! {
        didSet {
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
    @IBOutlet weak var labelText: UITextView! {
        didSet {
            labelText.textContainerInset = .zero
            labelText.delegate = self
        }
    }

    @IBOutlet weak var mediaViews: UIStackView!
    @IBOutlet weak var mediaViewsHeightConstraint: NSLayoutConstraint!

    static func cellMediaHeightFor(message: Message, sequential: Bool = true) -> CGFloat {
        let fullWidth = UIScreen.main.bounds.size.width
        let attributedString = MessageTextCacheManager.shared.message(for: message)
        let height = attributedString?.heightForView(withWidth: fullWidth - 62)

        var total = (height ?? 0) + (sequential ? 8 : 29)

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
                total += ChatMessageImageView.defaultHeight
            }

            if type == .video {
                total += ChatMessageVideoView.defaultHeight
            }

            if type == .audio {
                total += ChatMessageAudioView.defaultHeight
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
        labelText.text = ""
        labelDate.text = ""
        sequential = false
        rectsHighlight = nil

        for view in mediaViews.arrangedSubviews {
            view.removeFromSuperview()
        }
    }

    func insertGesturesIfNeeded() {
        if self.longPressGesture == nil {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressMessageCell(recognizer:)))
            gesture.minimumPressDuration = 0.5
            gesture.delegate = self
            self.addGestureRecognizer(gesture)
            self.longPressGesture = gesture
        }

        if self.labelTextTapGesture == nil {
            let gesture = UITapGestureRecognizer(target: self, action: #selector(handleHighlightsTapGestureCell(recognizer:)))
            gesture.delegate = self
            self.labelText.addGestureRecognizer(gesture)
            self.labelTextTapGesture = gesture
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
                    mediaViewHeight += ChatMessageImageView.defaultHeight
                }

            case .video:
                if let view = ChatMessageVideoView.instantiateFromNib() {
                    view.attachment = attachment
                    view.delegate = delegate
                    view.translatesAutoresizingMaskIntoConstraints = false

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight += ChatMessageVideoView.defaultHeight
                }

            case .audio:
                if let view = ChatMessageAudioView.instantiateFromNib() {
                    view.attachment = attachment
                    view.translatesAutoresizingMaskIntoConstraints = false

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight += ChatMessageAudioView.defaultHeight
                }

            default:
                return
            }
        }

        mediaViewsHeightConstraint.constant = CGFloat(mediaViewHeight)
    }

    fileprivate func updateMessageHeader() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        if let createdAt = message.createdAt {
            labelDate.text = formatter.string(from: createdAt)
        }

        avatarView.imageURL = URL(string: message.avatar)
        avatarView.user = message.user

        if message.alias.characters.count > 0 {
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

            labelText.attributedText = text
        }
    }

    fileprivate func setHighlights() {
        let attributes = NSMutableAttributedString(attributedString: labelText.attributedText)
        let fontAttribute = [NSAttributedStringKey.foregroundColor: UIColor.link]

        for range in labelText.text.matches(of: Regex.hashtag.rawValue) {
            let _range = NSRange(range, in: labelText.text)

            attributes.addAttributes(fontAttribute, range: _range)
        }

        labelText.attributedText = attributes
    }

    fileprivate func fillRectHighlights() {
        rectsHighlight = [:]

        for range in labelText.text.matches(of: Regex.hashtag.rawValue) {
            let startOffset = labelText.text.distance(from: labelText.text.startIndex, to: range.lowerBound)
            let rangeLength = labelText.text.distance(from: range.lowerBound, to: range.upperBound)

            guard
                let start = labelText.position(from: labelText.beginningOfDocument, offset: startOffset),
                let end = labelText.position(from: start, offset: rangeLength),

                let textRange = labelText.textRange(from: start, to: end) else {
                continue
            }

            let rect = labelText.firstRect(for: textRange)
            rectsHighlight?[rect] = labelText.text(in: textRange)
        }
    }

    fileprivate func updateMessage() {
        guard delegate != nil else { return }

        if !sequential {
            updateMessageHeader()
        }

        updateMessageContent()
        setHighlights()

        insertGesturesIfNeeded()
        insertAttachments()
    }

    override func layoutSubviews() {
        super.layoutSubviews()

        fillRectHighlights()
    }

    @objc func handleLongPressMessageCell(recognizer: UIGestureRecognizer) {
        delegate?.handleLongPressMessageCell(message, view: contentView, recognizer: recognizer)
    }

    @objc func handleHighlightsTapGestureCell(recognizer: UIGestureRecognizer) {
        guard let recognizer = recognizer as? UITapGestureRecognizer else { return }

        let point = recognizer.location(in: labelText)

        guard let first = rectsHighlight?.first(where: { $0.key.contains(point) }) else { return }

        print(first)
        // TODO
    }
}

extension ChatMessageCell: UIGestureRecognizerDelegate {

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return false
    }

}

extension ChatMessageCell: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange) -> Bool {
        if URL.scheme == "http" || URL.scheme == "https" {
            delegate?.openURL(url: URL)
            return false
        }

        return true
    }
}

extension CGRect: Hashable {
    public var hashValue: Int {
        return NSStringFromCGRect(self).hashValue
    }
}

extension String {
    fileprivate func matches(of regex: String) -> [Range<String.Index>] {
        var ranges: [Range<String.Index>] = []
        var start = self.startIndex
        while let range = self.range(of: regex, options: .regularExpression, range: start..<self.endIndex) {

            ranges.append(range)
            start = range.upperBound
        }

        return ranges
    }
}
