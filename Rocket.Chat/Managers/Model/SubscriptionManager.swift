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

    // swiftlint:disable function_body_length
    static func updateSubscriptions(_ auth: Auth, completion: @escaping MessageCompletion) {
        var params: [[String: Any]] = []

        if let lastUpdated = auth.lastSubscriptionFetch {
            params.append(["$date": Date.intervalFromDate(lastUpdated)])
        }

        let requestSubscriptions = [
            "msg": "method",
            "method": "subscriptions/get",
            "params": params
        ] as [String : Any]

        let requestRooms = [
            "msg": "method",
            "method": "rooms/get",
            "params": params
        ] as [String : Any]

        func executeRoomsRequest() {
            SocketManager.send(requestRooms) { response in
                guard !response.isError() else { return Log.debug(response.result.string) }

                let subscriptions = List<Subscription>()

                // List is used the first time user opens the app
                let list = response.result["result"].array

                // Update is used on updates
                let updated = response.result["result"]["update"].array

                Realm.execute({ realm in
                    guard let auth = AuthManager.isAuthenticated() else { return }

                    list?.forEach { object in
                        if let rid = object["_id"].string {
                            if let subscription = Subscription.find(rid: rid, realm: realm) {
                                subscription.roomDescription = object["description"].string ?? ""
                                subscription.roomTopic = object["topic"].string ?? ""
                                subscriptions.append(subscription)
                            }
                        }
                    }

                    updated?.forEach { object in
                        if let rid = object["_id"].string {
                            if let subscription = Subscription.find(rid: rid, realm: realm) {
                                subscription.roomDescription = object["description"].string ?? ""
                                subscription.roomTopic = object["topic"].string ?? ""
                                subscriptions.append(subscription)
                            }
                        }
                    }

                    auth.lastSubscriptionFetch = Date()
                    realm.add(subscriptions, update: true)

                    DispatchQueue.main.async {
                        completion(response)
                    }
                })
            }
        }

        SocketManager.send(requestSubscriptions) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let subscriptions = List<Subscription>()

            // List is used the first time user opens the app
            let list = response.result["result"].array

            // Update & Removed is used on updates
            let updated = response.result["result"]["update"].array
            let removed = response.result["result"]["remove"].array

            Realm.execute({ realm in
                guard let auth = AuthManager.isAuthenticated() else { return }

                list?.forEach { object in
                    let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                        object?.auth = auth
                    })

                    subscriptions.append(subscription)
                }

                updated?.forEach { object in
                    let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                        object?.auth = auth
                    })

                    subscriptions.append(subscription)
                }

                removed?.forEach { object in
                    let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                        object?.auth = nil
                    })

                    subscriptions.append(subscription)
                }

                auth.lastSubscriptionFetch = Date()

                realm.add(subscriptions, update: true)
                realm.add(auth, update: true)

                DispatchQueue.main.async {
                    executeRoomsRequest()
                }
            })
        }
    }

    static func changes(_ auth: Auth) {
        let eventName = "\(auth.userId ?? "")/subscriptions-changed"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "params": [eventName, false]
        ] as [String : Any]

        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let msg = response.result["fields"]["args"][0]
            let object = response.result["fields"]["args"][1]

            Realm.execute({ (realm) in
                guard let auth = AuthManager.isAuthenticated() else { return }
                let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                    object?.auth = msg == "removed" ? nil : auth
                })

                realm.add(subscription, update: true)
            })
        }
    }

    // MARK: Search

    static func spotlight(_ text: String, completion: @escaping MessageCompletionObjectsList<Subscription>) {
        let request = [
            "msg": "method",
            "method": "spotlight",
            "params": [text, NSNull(), ["rooms": true, "users": true]]
        ] as [String : Any]

        SocketManager.send(request) { response in
            guard !response.isError() else {
                completion([])
                return Log.debug(response.result.string)
            }

            var subscriptions = [Subscription]()
            let rooms = response.result["result"]["rooms"].array
            let users = response.result["result"]["users"].array

            Realm.execute({ (realm) in
                rooms?.forEach { object in
                    let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                        object?.rid = object?.identifier ?? ""
                    })

                    subscriptions.append(subscription)
                }

                users?.forEach { object in
                    let user = User.getOrCreate(realm: realm, values: object, updates: nil)
                    let subscription = Subscription()
                    subscription.identifier = user.identifier ?? ""
                    subscription.otherUserId = user.identifier
                    subscription.type = .directMessage
                    subscription.name = user.username ?? ""
                    subscriptions.append(subscription)
                }

                realm.add(subscriptions, update: true)

                DispatchQueue.main.async {
                    completion(subscriptions)
                }
            })
        }
    }

    // MARK: Rooms, Groups & DMs

    static func createDirectMessage(_ username: String, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "createDirectMessage",
            "params": [username]
        ] as [String : Any]

        SocketManager.send(request) { response in
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

        SocketManager.send(request) { response in
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

        SocketManager.send(request) { response in
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

    static func toggleFavorite(_ subscription: Subscription, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "toggleFavorite",
            "params": [subscription.rid, !subscription.favorite]
        ] as [String : Any]

        SocketManager.send(request, completion: completion)
    }
}
