//
//  ChatURLCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatURLCell: UICollectionViewCell {
    
    static let minimumHeight = CGFloat(110)
    static let identifier = "ChatURLCell"

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
    @IBOutlet weak var labelText: UILabel!
    
    @IBOutlet weak var imageViewURL: UIImageView! {
        didSet {
            imageViewURL.layer.masksToBounds = true
        }
    }

    @IBOutlet weak var labelURLTitle: UILabel!
    @IBOutlet weak var labelURLDescription: UILabel!
    
    override func prepareForReuse() {
        labelUsername.text = ""
        labelText.text = ""
        labelDate.text = ""
        labelURLTitle.text = ""
        labelURLDescription.text = ""
    }
    
    fileprivate func updateMessageInformation() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        labelDate.text = formatter.string(from: message.createdAt! as Date)
        
        avatarView.user = message.user
        
        labelUsername.text = message.user?.username
        labelText.text = Emojione.transform(string: message.text)
        
        if let url = message.urls.first {
            labelURLTitle.text = url.title
            labelURLDescription.text = url.textDescription
            
            if let imageURL = URL(string: url.imageURL ?? "") {
                imageViewURL.sd_setImage(with: imageURL)
            }
        }
    }
    
}
