//
//  UserManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/17/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

struct UserManager {
    
    // This needs to be called just once
    static func subscribeAllActive(completion: MessageCompletion) {
        let request = [
            "msg": "sub",
            "name": "activeUsers",
            "params": []
        ]
        
        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }
    
}