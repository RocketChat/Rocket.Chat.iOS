//
//  ChatTextCell.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import UIKit

class ChatTextCell: UICollectionViewCell {
    
    static let identifier = "ChatTextCell"

    var message: Message! {
        didSet {
            updateMessageInformation()
        }
    }
    
    @IBOutlet weak var labelText: UILabel!
    
    private func updateMessageInformation() {
        labelText.text = message.text
    }
    
}