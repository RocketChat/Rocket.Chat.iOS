//
//  MessageManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift


struct MessageManager {
    static let historySize = 50
}


extension MessageManager {
    
    static func getHistory(_ subscription: Subscription, lastMessageDate: Date?, completion: @escaping MessageCompletion) {
        var lastDate: Any!
        
        if let lastMessageDate = lastMessageDate {
            lastDate = ["$date": lastMessageDate.timeIntervalSince1970 * 1000]
        } else {
            lastDate = NSNull()
        }
        
        let request = [
            "msg": "method",
            "method": "loadHistory",
            "params": ["\(subscription.rid)", lastDate, historySize, [
                "$date": Date().timeIntervalSince1970 * 1000
            ]]
        ] as [String : Any]
        
        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            
            let messages = List<Message>()
            let list = response.result["result"]["messages"].array
            
            list?.forEach({ (obj) in
                let message = Message(dict: obj)
                message.subscription = subscription
                messages.append(message)
            })
            
            Realm.update(messages)
            completion(response)
        }
    }
    
    static func changes(_ subscription: Subscription) {
        let eventName = "\(subscription.rid)"
        let request = [
            "msg": "sub",
            "name": "stream-room-messages",
            "params": [eventName, false]
        ] as [String : Any]
        
        SocketManager.subscribe(request, eventName: eventName) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            
            let object = response.result["fields"]["args"][0]
            let message = Message(dict: object)
            message.subscription = subscription
            
            Realm.update(message)
        }
    }

}
