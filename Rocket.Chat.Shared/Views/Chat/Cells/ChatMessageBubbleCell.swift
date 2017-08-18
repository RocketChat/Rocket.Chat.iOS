//
//  ChatMessageBubbleCell.swift
//  Rocket.Chat
//
//  Created by Lucas Woo on 7/5/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatMessageBubbleCell: UICollectionViewCell, MessageTextCacheManagerInjected {

    static let receivedIdentifier = "ReceivedMessageBubble"
    static let sentIdendifier = "SentMessageBubble"

    private static let messageContentMinimumHeight: CGFloat = 18
    private static let bubbleMinimumHeight: CGFloat = messageContentMinimumHeight + bubblePadding

    /// Bubble width proportion to cell view
    private static let bubbleWidthProportion: CGFloat = 0.72

    /// Sum of top and bottom margin of bubble
    private static let bubbleVerticalMargin: CGFloat = 2

    /// Sum of top and bottom padding of bubble
    private static let bubblePadding: CGFloat = 12

    /// Left margin if is receivedBubble, right if sentBubble
    private static let bubbleStartMargin: CGFloat = 20

    // MARK: - computation conveniences

    let hornHeight: CGFloat = 30
    var hornCenterPoint: CGPoint {
        switch type {
        case .normal:
            return CGPoint.zero
        case .receivedBubble:
            return CGPoint(x: ChatMessageBubbleCell.bubbleStartMargin, y: frame.size.height - ChatMessageBubbleCell.bubbleVerticalMargin - hornHeight / 2)
        case .sentBubble:
            return CGPoint(x: frame.size.width - ChatMessageBubbleCell.bubbleStartMargin, y: frame.size.height - ChatMessageBubbleCell.bubbleVerticalMargin - hornHeight / 2)
        }
    }
    var hornZeroPoint: CGPoint {
        switch type {
        case .normal:
            return CGPoint.zero
        case .receivedBubble:
            return CGPoint(x: hornCenterPoint.x - hornHeight / 2, y: hornCenterPoint.y - hornHeight / 2)
        case .sentBubble:
            return CGPoint(x: hornCenterPoint.x + hornHeight / 2, y: hornCenterPoint.y - hornHeight / 2)
        }
    }

    var bubbleHornLayer: CAShapeLayer?

    weak var longPressGesture: UILongPressGestureRecognizer?
    weak var delegate: ChatMessageCellProtocol?
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
        bubbleView.layer.cornerRadius = ChatMessageBubbleCell.bubbleMinimumHeight / 2
        messageTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)

        self.contentMode = .redraw
    }

    static func cellSizeFor(_ width: CGFloat, message: Message, style: MessageContainerStyle, grouped: Bool = true, messageTextCacheManager: MessageTextCacheManager) -> CGSize {
        let size = UILabel.sizeForView(
            messageTextCacheManager.message(for: message, style: style)?.string ?? "",
            font: MessageTextFontAttributes.font(for: style),
            width: width * ChatMessageBubbleCell.bubbleWidthProportion - ChatMessageBubbleCell.bubblePadding,
            lineBreakMode: .byWordWrapping
        )
        var total = size.height

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

        if total < ChatMessageBubbleCell.messageContentMinimumHeight {
            total = ChatMessageBubbleCell.messageContentMinimumHeight
        }
        total += ChatMessageBubbleCell.bubblePadding + ChatMessageBubbleCell.bubbleVerticalMargin

        return CGSize(width: width, height: total)
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

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        bubbleHornLayer?.removeFromSuperlayer()
        bubbleHornLayer = CAShapeLayer()
        switch type {
        case .normal:
            break
        case .receivedBubble:
            let path = UIBezierPath()

            path.move(to: hornCenterPoint)
            path.addArc(withCenter: CGPoint(x: hornCenterPoint.x - hornHeight / 2, y: hornCenterPoint.y), radius: hornHeight / 2, startAngle: 0.0.radius, endAngle: 90.0.radius, clockwise: true)
            path.addArc(withCenter: hornZeroPoint, radius: hornHeight, startAngle: 90.0.radius, endAngle: 0.0.radius, clockwise: false)
            path.close()

            guard let hornLayer = bubbleHornLayer else { return }
            hornLayer.path = path.cgPath
            hornLayer.fillColor = UIColor.rcReceivedBubble.cgColor
            self.layer.addSublayer(hornLayer)
        case .sentBubble:
            let path = UIBezierPath()

            path.move(to: hornCenterPoint)
            path.addArc(withCenter: CGPoint(x: hornCenterPoint.x + hornHeight / 2, y: hornCenterPoint.y), radius: hornHeight / 2, startAngle: 180.0.radius, endAngle: 90.0.radius, clockwise: false)
            path.addArc(withCenter: hornZeroPoint, radius: hornHeight, startAngle: 90.0.radius, endAngle: 180.0.radius, clockwise: true)
            path.close()

            guard let hornLayer = bubbleHornLayer else { return }
            hornLayer.path = path.cgPath
            hornLayer.fillColor = UIColor.rcSentBubble.cgColor
            self.layer.addSublayer(hornLayer)
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
