//
//  SubscriptionManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/9/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

class SubscriptionManager {
    
    static func allSubscriptions(auth: Auth) {
        let request = [
            "msg": "method",
            "method": "subscriptions/get",
            "params": []
        ]

        SocketManager.sendMessage(request) { (response) in
            guard !response.isError() else {
                return print(response.result)
            }
            
            if let result = response.result["result"].array {
                for obj in result {
                    
                }
            }
        }
    }
    
}