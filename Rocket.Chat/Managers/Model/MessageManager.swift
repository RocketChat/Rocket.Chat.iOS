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
                    let message = Message(object: obj)
                    message.subscription = subscription
                    messages.append(message)
                }
            }
            
            Realm.execute() { (realm) in
                realm.add(messages, update: true)
            }
            
            completion(response)
        }
    }

}