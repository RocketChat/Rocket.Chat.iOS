//
//  ChatTextCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

protocol ChatMessageCellProtocol: ChatMessageURLViewProtocol, ChatMessageVideoViewProtocol {
    
}

class ChatMessageCell: UICollectionViewCell {
    
    static let minimumHeight = CGFloat(55)
    static let identifier = "ChatMessageCell"

    var delegate: ChatMessageCellProtocol?
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
        labelDate.text = formatter.string(from: message.createdAt! as Date)
        
        avatarView.user = message.user
        
        labelUsername.text = message.user?.username
        labelText.text = Emojione.transform(string: message.text)
        
        var mediaViewHeight = CGFloat(0)
        
        for url in message.urls {
            guard url.isValid() else { continue }
            let view = ChatMessageURLView.instanceFromNib() as! ChatMessageURLView
            view.url = url
            view.delegate = delegate

            mediaViews.addArrangedSubview(view)
            mediaViewHeight = mediaViewHeight + ChatMessageURLView.defaultHeight
        }
        
        for attachment in message.attachments {
            let type = attachment.type

            if type == .image {
                let view = ChatMessageImageView.instanceFromNib() as! ChatMessageImageView
                view.attachment = attachment
                mediaViews.addArrangedSubview(view)
                mediaViewHeight = mediaViewHeight + ChatMessageImageView.defaultHeight
            }
            
            if type == .video {
                let view = ChatMessageVideoView.instanceFromNib() as! ChatMessageVideoView
                view.attachment = attachment
                view.delegate = delegate

                mediaViews.addArrangedSubview(view)
                mediaViewHeight = mediaViewHeight + ChatMessageVideoView.defaultHeight
            }
        }
        
        mediaViewsHeightConstraint.constant = CGFloat(mediaViewHeight)
    }
    
}
