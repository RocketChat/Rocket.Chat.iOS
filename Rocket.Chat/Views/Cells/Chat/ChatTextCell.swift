//
//  ChatTextCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit
import SDWebImage

class ChatTextCell: UICollectionViewCell {
    
    static let minimumHeight = CGFloat(55)
    static let identifier = "ChatTextCell"

    var message: Message! {
        didSet {
            updateMessageInformation()
        }
    }
    
    @IBOutlet weak var imageView: UIImageView! {
        didSet {
            imageView.layer.masksToBounds = true
            imageView.layer.cornerRadius = 4
        }
    }

    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelText: UILabel!
    
    fileprivate func updateMessageInformation() {
        let formatter = DateFormatter()
        formatter.timeStyle = .short

        if let imageURL = message.userAvatarURL() {
            imageView.sd_setImage(with: imageURL as URL!)
        }

        labelDate.text = formatter.string(from: message.createdAt! as Date)
        labelUsername.text = message.user?.username
        labelText.text = message.text
        labelText.sizeToFit()
    }
    
}
