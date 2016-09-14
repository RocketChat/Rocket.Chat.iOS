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

    @IBOutlet weak var avatarView: AvatarView!
    @IBOutlet weak var labelDate: UILabel!
    @IBOutlet weak var labelUsername: UILabel!
    @IBOutlet weak var labelText: UILabel!
    
    private func updateMessageInformation() {
        let formatter = NSDateFormatter()
        formatter.timeStyle = .ShortStyle

        avatarView.user = message.user
        labelDate.text = formatter.stringFromDate(message.createdAt!)
        labelUsername.text = message.user?.username
        labelText.text = message.text
        labelText.sizeToFit()
    }
    
}