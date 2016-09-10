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
    
    private func updateMessageInformation() {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle

        if let imageURL = message.userAvatarURL() {
            imageView.sd_setImageWithURL(imageURL)
        }

        labelDate.text = formatter.stringFromDate(message.createdAt!)
        labelUsername.text = message.user?.username
        labelText.text = message.text
        labelText.sizeToFit()
    }
    
}