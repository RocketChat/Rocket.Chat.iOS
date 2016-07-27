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
    
    static let identifier = "ChatTextCell"

    var message: Message! {
        didSet {
            updateMessageInformation()
        }
    }
    
    
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelText: UILabel!
    
    private func updateMessageInformation() {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle

        imageView.sd_setImageWithURL(message.userAvatarURL())
        labelDate.text = formatter.stringFromDate(message.createdAt!)
        labelUsername.text = message.user?.username
        labelText.text = message.text
        
    }
    
}