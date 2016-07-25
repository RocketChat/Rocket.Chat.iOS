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

        SocketManager.send(request) { (response) in
            guard !response.isError() else {
                return print(response.result)
            }
            
            let subscriptions = List<Subscription>()
            if let result = response.result["result"].array {
                for obj in result {
                    let subscription = Subscription(object: obj)
                    subscription.auth = auth

                    subscriptions.append(subscription)
                }
            }
            
            Realm.execute() { (realm) in
                realm.add(subscriptions, update: true)
            }
            
            completion(response)
        }
    }
    
    static func changes(auth: Auth, completion: MessageCompletion) {
        let eventName = "\(auth.userId!)/subscriptions-changed"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "params": [eventName, false]
        ]
        
        SocketManager.subscribe(request, eventName: eventName) { (response) in
            guard !response.isError() else {
                return print(response.result)
            }
            
            let object = response.result["fields"]["args"][1]
            let subscription = Subscription(object: object)
            subscription.auth = auth
            
            Realm.execute() { (realm) in
                realm.add(subscription, update: true)
            }
            
            completion(response)
        }
    }
    
}

