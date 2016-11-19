//
//  ChatPreviewModeView.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 19/11/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatPreviewModeView: BaseView {
    
    var subscription: Subscription! {
        didSet {
            let format = localizedString("chat.channel_preview_view.title")
            let string = String(format: format, subscription.name)
            labelTitle.text = string
        }
    }
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonJoin: UIButton! {
        didSet {
            buttonJoin.layer.cornerRadius = 4
            buttonJoin.setTitle(localizedString("chat.channel_preview_view.join"), for: .normal)
        }
    }

    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
}
