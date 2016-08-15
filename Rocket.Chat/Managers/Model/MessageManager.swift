//
//  MessageManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift


class MessageManager {
    
    static let historySize = 50
    
}


extension MessageManager {
    
    static func fetchHistory(subscription: Subscription, completion: MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "loadHistory",
            "params": ["\(subscription.rid)", NSNull(), historySize, [
                "$date": NSDate().timeIntervalSince1970 * 1000
            ]]
        ]
        
        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            
            let messages = List<Message>()
            let list = response.result["result"]["messages"].array
            
            list?.forEach({ (obj) in
                let message = Message(object: obj)
                message.subscription = subscription
                messages.append(message)
            })
            
            Realm.update(messages)
            completion(response)
        }
    }
    
    static func changes(subscription: Subscription, completion: MessageCompletion) {
        let eventName = "\(subscription.rid)"
        let request = [
            "msg": "sub",
            "name": "stream-room-messages",
            "params": [eventName, false]
        ]
        
        SocketManager.subscribe(request, eventName: eventName) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            
            let object = response.result["fields"]["args"][0]
            let message = Message(object: object)
            message.subscription = subscription
            
            Realm.update(message)
            completion(response)
        }
    }

}