//
//  ChatMessageActionButtonsView.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 09/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatMessageActionButtonsView: UIView {

     static let defaultHeight = CGFloat(55)

    @IBOutlet weak var buttonReply: UIButton! {
        didSet {
            let buttonColor = UIColor.RCBlue()
            buttonReply.tintColor = buttonColor
            buttonReply.layer.borderColor = buttonColor.cgColor
            buttonReply.layer.borderWidth = 1
            buttonReply.layer.cornerRadius = 4
        }
    }

}
