//
//  ChatImageCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 03/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit
import SDWebImage

class ChatImageCell: UICollectionViewCell {
    
    static let minimumHeight = CGFloat(270)
    static let identifier = "ChatImageCell"
    
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
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.cornerRadius = 4
            imageView.layer.borderColor = UIColor.lightGray.withAlphaComponent(0.1).cgColor
            imageView.layer.borderWidth = 0.5
        }
    }
    
    fileprivate func updateMessageInformation() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        labelDate.text = formatter.string(from: message.createdAt! as Date)
        
        avatarView.user = message.user
        
        labelUsername.text = message.user?.username
        
        guard let attachment = message.attachments.first else { return }
        let imageURL = Attachment.fullImageURL(attachment)
        imageView.sd_setImage(with: imageURL, completed: { (image, error, cacheType, imageURL) in
            print(error ?? "OK")
        })
    }
}
