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
            
            let msg = response.result["fields"]["args"][0]
            let object = response.result["fields"]["args"][1]
            
            if msg == "removed" {
                let subscription = Subscription(dict: object)
                subscription.auth = nil
                Realm.update(subscription)
            } else {
                let subscription = Subscription(dict: object)
                subscription.auth = auth
                Realm.update(subscription)
            }
        }
    }
    
    
    // MARK: Search
    
    static func spotlight(_ text: String, completion: @escaping MessageCompletionObjectsList<Subscription>) {
        let request = [
            "msg": "method",
            "method": "spotlight",
            "params": [text, NSNull(), ["rooms": true, "users": true]]
        ] as [String : Any]
        
        SocketManager.send(request) { (response) in
            guard !response.isError() else {
                completion([])
                return Log.debug(response.result.string)
            }
            
            var subscriptions = [Subscription]()
            let rooms = response.result["result"]["rooms"].array
            let users = response.result["result"]["users"].array
            
            rooms?.forEach({ (obj) in
                let subscription = Subscription(dict: obj)
                subscription.rid = subscription.identifier ?? ""
                subscriptions.append(subscription)
            })
            
            users?.forEach({ (obj) in
                let user = User(dict: obj)
                let subscription = Subscription()
                subscription.identifier = user.identifier ?? ""
                subscription.otherUserId = user.identifier
                subscription.type = .directMessage
                subscription.name = user.username ?? ""
                subscriptions.append(subscription)
            })
            
            Realm.execute({ (realm) in
                realm.add(subscriptions, update: true)
            })
        
            completion(subscriptions)
        }
    }
    
    
    // MARK: Rooms, Groups & DMs
    
    static func createDirectMessage(_ username: String, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "createDirectMessage",
            "params": [username]
        ] as [String : Any]
        
        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }
    
    static func getRoom(byName name: String, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "getRoomByTypeAndName",
            "params": ["c", name]
        ] as [String : Any]
        
        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }
    
    static func join(room rid: String, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "joinRoom",
            "params": [rid]
        ] as [String : Any]
        
        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }
    
    
    // MARK: Messages
    
    static func markAsRead(_ subscription: Subscription, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "readMessages",
            "params": [subscription.rid]
        ] as [String : Any]
        
        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }
    
    static func sendTextMessage(_ message: String, subscription: Subscription, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "sendMessage",
            "params": [[
                "_id": String.random(18),
                "rid": subscription.rid,
                "msg": message
            ]]
        ] as [String : Any]
        
        SocketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }
    
}

