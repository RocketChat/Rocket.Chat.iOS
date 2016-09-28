//
//  SubscriptionManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/9/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

struct SubscriptionManager {
    
    static func updateSubscriptions(_ auth: Auth, completion: @escaping MessageCompletion) {
        var params: [[String: Any]] = []

        if let lastUpdated = auth.lastSubscriptionFetch {
            params.append(["$date": Date.intervalFromDate(lastUpdated)])
        }

        let request = [
            "msg": "method",
            "method": "subscriptions/get",
            "params": params
        ] as [String : Any]

        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            
            let subscriptions = List<Subscription>()
            let list = response.result["result"].array

            list?.forEach({ (obj) in
                let subscription = Subscription(dict: obj)
                subscription.auth = auth
                subscriptions.append(subscription)
            })
            
            Realm.execute({ (realm) in
                auth.lastSubscriptionFetch = Date()

                realm.add(subscriptions, update: true)
                realm.add(auth, update: true)
            })

            completion(response)
        }
    }
    
    static func changes(_ auth: Auth) {
        let eventName = "\(auth.userId!)/subscriptions-changed"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "params": [eventName, false]
        ] as [String : Any]
        
        SocketManager.subscribe(request, eventName: eventName) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            
            let object = response.result["fields"]["args"][1]
            let subscription = Subscription(dict: object)
            subscription.auth = auth
            
            Realm.update(subscription)
        }
    }
    
}

