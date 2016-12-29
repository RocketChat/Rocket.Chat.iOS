//
//  ChatTextCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatMessageCellProtocol: ChatMessageURLViewProtocol, ChatMessageVideoViewProtocol, ChatMessageImageViewProtocol {
    func openURL(url: URL)
}

class ChatMessageCell: UICollectionViewCell {

    static let minimumHeight = CGFloat(55)
    static let identifier = "ChatMessageCell"

    weak var delegate: ChatMessageCellProtocol?
    var message: Message! {
        didSet {
            updateMessageInformation()
        }
    }

    @IBOutlet weak var avatarView: AvatarView! {
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

    static func cellMediaHeightFor(message: Message, grouped: Bool = true) -> CGFloat {
        let fullWidth = UIScreen.main.bounds.size.width
        var total = UILabel.heightForView(
            message.text,
            font: UIFont.systemFont(ofSize: 14),
            width: fullWidth - 60
        ) + 35

        for url in message.urls {
            guard url.isValid() else { continue }
            total = total + ChatMessageURLView.defaultHeight
        }

        for attachment in message.attachments {
            let type = attachment.type

            if type == .image {
                total = total + ChatMessageImageView.defaultHeight
            }

            if type == .video {
                total = total + ChatMessageVideoView.defaultHeight
            }
        }

        return total
    }

    override func prepareForReuse() {
        labelUsername.text = ""
        labelText.text = ""
        labelDate.text = ""

        for view in mediaViews.arrangedSubviews {
            view.removeFromSuperview()
        }
    }

    fileprivate func updateMessageInformation() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        if let createdAt = message.createdAt {
            labelDate.text = formatter.string(from: createdAt)
        }

        avatarView.user = message.user

        labelUsername.text = message.user?.username
        labelText.text = Emojione.transform(string: message.text)

        var mediaViewHeight = CGFloat(0)

        message.urls.forEach { url in
            guard url.isValid() else { return }
            if let view = ChatMessageURLView.instanceFromNib() as? ChatMessageURLView {
                view.url = url
                view.delegate = delegate

                mediaViews.addArrangedSubview(view)
                mediaViewHeight = mediaViewHeight + ChatMessageURLView.defaultHeight
            }
        }

        message.attachments.forEach { attachment in
            let type = attachment.type

            switch type {
            case .image:
                if let view = ChatMessageImageView.instanceFromNib() as? ChatMessageImageView {
                    view.attachment = attachment
                    view.delegate = delegate

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight = mediaViewHeight + ChatMessageImageView.defaultHeight
                }

            case .video:
                if let view = ChatMessageVideoView.instanceFromNib() as? ChatMessageVideoView {
                    view.attachment = attachment
                    view.delegate = delegate

                    mediaViews.addArrangedSubview(view)
                    mediaViewHeight = mediaViewHeight + ChatMessageVideoView.defaultHeight
                }
            default:
                return
            }
        }

        mediaViewsHeightConstraint.constant = CGFloat(mediaViewHeight)
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
