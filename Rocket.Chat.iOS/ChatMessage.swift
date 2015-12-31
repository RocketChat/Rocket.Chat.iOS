//
//  ChatMessage.swift
//  Rocket.Chat.iOS
//
//  Created by Kornelakis Michael on 11/6/15.
//  Copyright © 2015 Rocket.Chat. All rights reserved.
//

import UIKit

class ChatMessage {

    var rid = String()
    var userId = String()
    var username = String()
    var message = String()
    var messageType = String()
    var timestamp = Double()
    
    
    
    init(rid: String ,user_id: String, username: String, msg: String, msgType: String, ts: Double?){

        self.rid = rid
        self.userId = user_id
        self.username = username
        self.message = msg
        self.messageType = msgType
        self.timestamp = ts!
        
    }
    
    convenience init() {
        self.init(rid: String(), user_id: String(), username: String(), msg: String(), msgType: String(), ts: Double())
    }
    
    
}

