//
//  SubscriptionManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/9/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

class SubscriptionManager {
    
    static func updateSubscriptions(auth: Auth, completion: MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "subscriptions/get",
            "params": []
        ]

        SocketManager.sendMessage(request) { (response) in
            guard !response.isError() else {
                return print(response.result)
            }
            
            let subscriptions = List<Subscription>()
            if let result = response.result["result"].array {
                for obj in result {
                    let subscription = Subscription()
                    subscription.identifier = obj["_id"].string!
                    subscription.rid = obj["rid"].string!
                    subscription.name = obj["name"].string!
                    subscription.unread = obj["unread"].int ?? 0
                    subscription.open = obj["open"].bool ?? false
                    subscription.alert = obj["alert"].bool ?? false
                    subscription.favorite = obj["f"].bool ?? false
                    
                    if let createdAt = obj["ts"]["$date"].double {
                        subscription.createdAt = NSDate.dateFromInterval(createdAt)
                    }
                    
                    if let lastSeen = obj["ls"]["$date"].double {
                        subscription.lastSeen = NSDate.dateFromInterval(lastSeen)
                    }

                    subscriptions.append(subscription)
                }
            }
            
            let realm = try! Realm()
            try! realm.write {
                realm.add(subscriptions, update: true)
                auth.subscriptions = subscriptions
            }
            
            completion(response)
        }
    }
    
}

