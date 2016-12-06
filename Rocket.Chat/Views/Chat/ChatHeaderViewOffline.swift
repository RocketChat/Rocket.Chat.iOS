//
//  ChatHeaderViewOffline.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 05/12/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatHeaderViewOffline: BaseView {
    
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var buttonRefresh: UIButton!
    
    @IBAction func buttonRefreshDidPressed(_ sender: Any) {
        SocketManager.reconnect()
    }
    
}
