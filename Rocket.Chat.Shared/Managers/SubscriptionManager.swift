//
//  SubscriptionManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/9/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

/// A manager that manages all subscription related actions
public class SubscriptionManager: SocketManagerInjected, AuthManagerInjected {

    /// Dependency injection container, replace it to change the behavior of the auth manager
    var injectionContainer: InjectionContainer!

    // swiftlint:disable function_body_length
    /// Updates all subscriptions information and stores them locally from remote server
    ///
    /// - Parameters:
    ///   - auth: the target server's auth instance
    ///   - completion: will be called after action completion
    func updateSubscriptions(_ auth: Auth, completion: @escaping MessageCompletion) {
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
            socketManager.send(requestRooms) { response in
                guard !response.isError() else { return Log.debug(response.result.string) }

                let subscriptions = List<Subscription>()

                // List is used the first time user opens the app
                let list = response.result["result"].array

                // Update is used on updates
                let updated = response.result["result"]["update"].array

                Realm.execute({ realm in
                    guard let auth = self.authManager.isAuthenticated() else { return }

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

        socketManager.send(requestSubscriptions) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let subscriptions = List<Subscription>()

            // List is used the first time user opens the app
            let list = response.result["result"].array

            // Update & Removed is used on updates
            let updated = response.result["result"]["update"].array
            let removed = response.result["result"]["remove"].array

            Realm.execute({ realm in
                guard let auth = self.authManager.isAuthenticated() else { return }

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

    func changes(_ auth: Auth) {
        let eventName = "\(auth.userId ?? "")/subscriptions-changed"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "params": [eventName, false]
        ] as [String : Any]

        socketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let msg = response.result["fields"]["args"][0]
            let object = response.result["fields"]["args"][1]

            Realm.execute({ (realm) in
                guard let auth = self.authManager.isAuthenticated() else { return }
                let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                    object?.auth = msg == "removed" ? nil : auth
                })

                realm.add(subscription, update: true)
            })
        }
    }

    // MARK: Search

    /// Search with given text for related subscriptions
    ///
    /// - Parameters:
    ///   - text: text to be searched
    ///   - completion: will be called after action completion
    func spotlight(_ text: String, completion: @escaping MessageCompletionObjectsList<Subscription>) {
        let request = [
            "msg": "method",
            "method": "spotlight",
            "params": [text, NSNull(), ["rooms": true, "users": true]]
        ] as [String : Any]

        socketManager.send(request) { response in
            guard !response.isError() else {
                completion([])
                return Log.debug(response.result.string)
            }

            var subscriptions = [Subscription]()
            var identifiers = [String]()
            let rooms = response.result["result"]["rooms"].array
            let users = response.result["result"]["users"].array

            Realm.execute({ (realm) in
                rooms?.forEach { object in
                    let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                        object?.rid = object?.identifier ?? ""
                    })

                    if let identifier = subscription.identifier {
                        identifiers.append(identifier)
                    }

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

                    if let identifier = subscription.identifier {
                        identifiers.append(identifier)
                    }
                }

                realm.add(subscriptions, update: true)
            }, completion: {
                var detachedSubscriptions = [Subscription]()

                Realm.executeOnMainThread({ (realm) in
                    for identifier in identifiers {
                        if let subscription = realm.object(ofType: Subscription.self, forPrimaryKey: identifier) {
                            detachedSubscriptions.append(subscription)
                        }
                    }
                })

                completion(detachedSubscriptions)
            })
        }
    }

    // MARK: Rooms, Groups & DMs

    /// Create a subscription to target user
    ///
    /// - Parameters:
    ///   - username: username of target user
    ///   - completion: will be called after action completion
    func createDirectMessage(_ username: String, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "createDirectMessage",
            "params": [username]
        ] as [String : Any]

        socketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    /// Get a room by room name
    ///
    /// - Parameters:
    ///   - name: room name
    ///   - completion: will be called after action completion
    func getRoom(byName name: String, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "getRoomByTypeAndName",
            "params": ["c", name]
        ] as [String : Any]

        socketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    /// Join a room by given room id
    ///
    /// - Parameters:
    ///   - rid: target room id
    ///   - completion: will be called after action completion
    func join(room rid: String, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "joinRoom",
            "params": [rid]
        ] as [String : Any]

        socketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    // MARK: Messages

    /// Mark any new messages of a subscription until now as read
    ///
    /// - Parameters:
    ///   - subscription: target subscription
    ///   - completion: will be called after action completion
    func markAsRead(_ subscription: Subscription, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "readMessages",
            "params": [subscription.rid]
        ] as [String : Any]

        socketManager.send(request) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    /// Send a text message to target subscription
    ///
    /// - Parameters:
    ///   - message: a message instance that contains the text and target subscription
    ///   - completion: will be called after action completion
    func sendTextMessage(_ message: Message, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "sendMessage",
            "params": [[
                "_id": message.identifier ?? "",
                "rid": message.subscription.rid,
                "msg": message.text
            ]]
        ] as [String : Any]

        socketManager.send(request) { (response) in
            guard !response.isError() else { return Log.debug(response.result.string) }
            completion(response)
        }
    }

    /// Toggle a subscription as favorite or not
    ///
    /// - Parameters:
    ///   - subscription: target subscription
    ///   - completion: will be called after action completion
    func toggleFavorite(_ subscription: Subscription, completion: @escaping MessageCompletion) {
        let request = [
            "msg": "method",
            "method": "toggleFavorite",
            "params": [subscription.rid, !subscription.favorite]
        ] as [String : Any]

        socketManager.send(request, completion: completion)
    }
}
