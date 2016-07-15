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


// MARK: Realm Data

extension MessageManager {
    
    static func allMessages(subscription: Subscription) -> Results<Message> {
        return try! Realm().objects(Message.self)
            .filter("subscription = %@", subscription)
            .sorted("createdAt", ascending: true)
    }
    
}



// MARK: History

extension MessageManager {
    
    static func fetchHistory(subscription: Subscription, completion: MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "loadHistory",
            "params": ["xSgZjSaWrcXoDR4QZ", NSNull(), historySize, [
                "$date": NSDate().timeIntervalSince1970 * 1000
            ]]
        ]
        
        SocketManager.send(request) { (response) in
            guard !response.isError() else {
                return print(response.result)
            }
            
            let messages = List<Message>()
            if let result = response.result["result"]["messages"].array {
                for obj in result {
                    let message = Message()
                    message.identifier = obj["_id"].string!
                    message.subscription = subscription
                    message.rid = obj["rid"].string!
                    message.text = obj["msg"].string!
                    
                    if let createdAt = obj["ts"]["$date"].double {
                        message.createdAt = NSDate.dateFromInterval(createdAt)
                    }
                    
                    if let updatedAt = obj["_updatedAt"]["$date"].double {
                        message.updatedAt = NSDate.dateFromInterval(updatedAt)
                    }
                    
                    messages.append(message)
                }
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(messages, update: true)
            }
            
            completion(response)
        }
    }

}