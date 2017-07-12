//
//  ChatMessageBubbleCell.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 7/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatMessageBubbleCell: UICollectionViewCell, MessageTextCacheManagerInjected {

    static let minimumHeight = 36 + bubbleHeightConstant
    static let receivedIdentifier = "ReceivedMessageBubble"
    static let sentIdendifier = "SentMessageBubble"

    private static let bubbleWidthProportion: CGFloat = 0.72
    private static let bubbleHeightConstant: CGFloat = 8
    private static let bubblePadding: CGFloat = 12

    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var delegate: ChatMessageCellProtocol?
    var injectionContainer: InjectionContainer!
    var message: Message! {
        didSet {
            updateMessageInformation()
        }
    }
    var type: MessageContainerStyle = .sentBubble

    @IBOutlet weak var bubbleView: UIView!
    @IBOutlet weak var messageTextView: UITextView! {
        didSet {
            messageTextView.textContainerInset = .zero
            messageTextView.delegate = self
        }
    }
    @IBOutlet weak var dateLabel: UILabel!
    var messageTextViewWidthAnchor: NSLayoutConstraint?

    override func awakeFromNib() {
        super.awakeFromNib()
        bubbleView.layer.cornerRadius = 18
        messageTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
    }

    static func cellSizeFor(message: Message, style: MessageContainerStyle, grouped: Bool = true, messageTextCacheManager: MessageTextCacheManager) -> CGSize {
        let fullWidth = UIScreen.main.bounds.size.width
        let size = UILabel.sizeForView(
            messageTextCacheManager.message(for: message, style: style)?.string ?? "",
            font: UIFont.systemFont(ofSize: 15),
            width: fullWidth * ChatMessageBubbleCell.bubbleWidthProportion - ChatMessageBubbleCell.bubblePadding
            )
        var total = size.height + ChatMessageBubbleCell.bubblePadding - ChatMessageBubbleCell.bubbleHeightConstant

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
        }

        return CGSize(width: size.width, height: total > ChatMessageBubbleCell.minimumHeight ? total : ChatMessageBubbleCell.minimumHeight)
    }

    override func prepareForReuse() {
        messageTextView.text = ""
        dateLabel.text = ""
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let size = messageTextView.sizeThatFits(CGSize(width: UIScreen.main.bounds.size.width * ChatMessageBubbleCell.bubbleWidthProportion - ChatMessageBubbleCell.bubblePadding, height: CGFloat.infinity))
        let width = size.width
        if messageTextViewWidthAnchor == nil {
            messageTextViewWidthAnchor = messageTextView.widthAnchor.constraint(equalToConstant: width)
            messageTextViewWidthAnchor?.priority = 500
        } else {
            messageTextViewWidthAnchor?.constant = width
        }
        messageTextViewWidthAnchor?.isActive = true
    }

    func insertGesturesIfNeeded() {
        if self.longPressGesture == nil {
            let gesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressMessageCell(recognizer:)))
            gesture.minimumPressDuration = 0.5
            gesture.delegate = self
            self.addGestureRecognizer(gesture)
            self.longPressGesture = gesture
        }
    }

    fileprivate func updateMessageInformation() {
        guard delegate != nil else { return }

        let formatter = DateFormatter()
        formatter.timeStyle = .short

        if let createdAt = message.createdAt {
            dateLabel.text = formatter.string(from: createdAt)
        }

        if let text = messageTextCacheManager.message(for: message, style: type) {
            messageTextView.attributedText = text
            messageTextView.sizeToFit()
        }
        
        insertGesturesIfNeeded()
        layoutIfNeeded()
    }
    
    func handleLongPressMessageCell(recognizer: UIGestureRecognizer) {
        delegate?.handleLongPressMessageCell(message, view: contentView, recognizer: recognizer)
    }
}

extension ChatMessageBubbleCell: UIGestureRecognizerDelegate {
    
}

extension ChatMessageBubbleCell: UITextViewDelegate {

}
