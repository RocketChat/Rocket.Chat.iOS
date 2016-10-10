//
//  ChatTitleView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 10/10/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatTitleView: UIView {
    
    @IBOutlet weak var icon: UIImageView! {
        didSet {
            icon.image = icon.image?.imageWithTint(UIColor(rgb: 0x5B5B5B, alphaVal: 0.35))
        }
    }

    @IBOutlet weak var labelTitle: UILabel! {
        didSet {
            labelTitle.textColor = UIColor(rgb: 0x5B5B5B, alphaVal: 1)
        }
    }
    
}
