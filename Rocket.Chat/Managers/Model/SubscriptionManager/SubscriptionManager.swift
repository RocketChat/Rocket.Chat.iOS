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
    static func updateUnreadApplicationBadge() {
        var unread = 0

        Realm.execute({ (realm) in
            for obj in realm.objects(Subscription.self) {
                unread += obj.unread
            }
        }, completion: {
            UIApplication.shared.applicationIconBadgeNumber = unread
        })
    }

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
        ] as [String: Any]

        let requestRooms = [
            "msg": "method",
            "method": "rooms/get",
            "params": params
        ] as [String: Any]

        let currentRealm = Realm.current

        func executeRoomsRequest() {
            SocketManager.send(requestRooms) { response in
                guard !response.isError() else { return Log.debug(response.result.string) }

                currentRealm?.execute({ realm in
                    guard let auth = AuthManager.isAuthenticated(realm: realm) else { return }
                    auth.lastSubscriptionFetch = Date.serverDate.addingTimeInterval(-1)
                    realm.add(auth, update: true)
                })

                let subscriptions = List<Subscription>()

                // List is used the first time user opens the app
                let list = response.result["result"].array

                // Update is used on updates
                let updated = response.result["result"]["update"].array

                currentRealm?.execute({ realm in
                    list?.forEach { object in
                        if let rid = object["_id"].string {
                            if let subscription = Subscription.find(rid: rid, realm: realm) {
                                subscription.mapRoom(object)
                                subscriptions.append(subscription)
                            }
                        }
                    }

                    updated?.forEach { object in
                        if let rid = object["_id"].string {
                            if let subscription = Subscription.find(rid: rid, realm: realm) {
                                subscription.mapRoom(object)
                                subscriptions.append(subscription)
                            }
                        }
                    }

                    realm.add(subscriptions, update: true)
                }, completion: {
                    completion(response)
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

            currentRealm?.execute({ realm in
                guard let auth = AuthManager.isAuthenticated(realm: realm) else { return }

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

                auth.lastSubscriptionFetch = Date.serverDate

                realm.add(subscriptions, update: true)
                realm.add(auth, update: true)

                DispatchQueue.main.async {
                    executeRoomsRequest()
                }
            })
        }
    }

    static func changes(_ auth: Auth) {
        guard !auth.isInvalidated else { return }

        let serverURL = auth.serverURL

        let eventName = "\(auth.userId ?? "")/subscriptions-changed"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "params": [eventName, false]
        ] as [String: Any]

        let currentRealm = Realm.current
        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let msg = response.result["fields"]["args"][0]
            let object = response.result["fields"]["args"][1]

            currentRealm?.execute({ (realm) in
                guard let auth = AuthManager.isAuthenticated(realm: realm), auth.serverURL == serverURL else { return }
                let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                    object?.auth = msg == "removed" ? nil : auth
                })

                realm.add(subscription, update: true)
            })
        }
    }

    static func subscribeRoomChanges() {
        guard let user = AuthManager.currentUser() else { return }

        let eventName = "\(user.identifier ?? "")/rooms-changed"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "params": [eventName, false]
        ] as [String: Any]

        let currentRealm = Realm.current
        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let object = response.result["fields"]["args"][1]

            currentRealm?.execute({ (realm) in
                if let rid = object["_id"].string {
                    if let subscription = Subscription.find(rid: rid, realm: realm) {
                        subscription.mapRoom(object)

                        realm.add(subscription, update: true)
                    }
                }
            })
        }
    }

    static func subscribeInAppNotifications() {
        guard let user = AuthManager.currentUser() else { return }

        let eventName = "\(user.identifier ?? "")/notification"
        let request = [
            "msg": "sub",
            "name": "stream-notify-user",
            "params": [eventName, false]
            ] as [String: Any]

        SocketManager.subscribe(request, eventName: eventName) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            let object = response.result["fields"]["args"][0]
            print(object)
            AppDelegate.displayNotification(title: object["title"].stringValue, body: object["text"].stringValue)

//            currentRealm?.execute({ (realm) in
//                if let rid = object["_id"].string {
//                    if let subscription = Subscription.find(rid: rid, realm: realm) {
//                        subscription.mapRoom(object)
//
//                        realm.add(subscription, update: true)
//                    }
//                }
//            })
        }
    }
}
