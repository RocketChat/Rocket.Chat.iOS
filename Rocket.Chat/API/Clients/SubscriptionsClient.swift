//
//  SubscriptionsClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import RealmSwift

struct SubscriptionsClient: APIClient {
    let api: AnyAPIFetcher
    init(api: AnyAPIFetcher) {
        self.api = api
    }

    func markAsRead(subscription: Subscription) {
        let req = SubscriptionReadRequest(rid: subscription.rid)

        api.fetch(req) { response in
            switch response {
            case .resource: break
            case .error(let error):
                if case .version = error {
                    SubscriptionManager.markAsRead(subscription, completion: { _ in })
                }
            }
        }
    }

    func fetchSubscriptions(updatedSince: Date?, realm: Realm? = Realm.current, completion: (() -> Void)? = nil) {
        let req = SubscriptionsRequest()

        let currentRealm = realm

        api.fetch(req, options: [.retryOnError(count: 3)]) { response in
            switch response {
            case .resource(let resource):
                guard resource.success == true else {
                    completion?()
                    return
                }

                let subscriptions = List<Subscription>()

                currentRealm?.execute({ realm in
                    guard let auth = AuthManager.isAuthenticated(realm: realm) else { return }

                    func queueSubscriptionForUpdate(_ subscription: Subscription) {
                        subscription.auth = auth
                        subscriptions.append(subscription)
                    }

                    resource.list?.forEach(queueSubscriptionForUpdate)
                    resource.update?.forEach(queueSubscriptionForUpdate)

                    resource.remove?.forEach { subscription in
                        subscription.auth = nil
                        subscriptions.append(subscription)
                    }

                    auth.lastSubscriptionFetchWithLastMessage = Date.serverDate

                    realm.add(subscriptions, update: true)
                    realm.add(auth, update: true)
                }, completion: completion)
            case .error(let error):
                switch error {
                case .version:
                    self.fetchSubscriptionsFallback(updatedSince: updatedSince, realm: realm, completion: completion)
                default:
                    completion?()
                }
            }
        }
    }

    func fetchRooms(updatedSince: Date?, realm: Realm? = Realm.current, completion: (() -> Void)? = nil) {
        let req = RoomsRequest()

        let currentRealm = realm

        api.fetch(req, options: [.retryOnError(count: 3)]) { response in
            switch response {
            case .resource(let resource):
                guard resource.success == true else {
                    completion?()
                    return
                }

                currentRealm?.execute({ realm in
                    guard let auth = AuthManager.isAuthenticated(realm: realm) else { return }
                    auth.lastSubscriptionFetchWithLastMessage = Date.serverDate.addingTimeInterval(-1)
                    realm.add(auth, update: true)
                })

                let subscriptions = List<Subscription>()

                currentRealm?.execute({ realm in
                    func queueRoomValuesForUpdate(_ object: JSON) {
                        guard
                            let rid = object["_id"].string,
                            let subscription = Subscription.find(rid: rid, realm: realm)
                        else {
                            return
                        }

                        subscription.mapRoom(object, realm: realm)
                        subscriptions.append(subscription)
                    }

                    resource.list?.forEach(queueRoomValuesForUpdate)
                    resource.update?.forEach(queueRoomValuesForUpdate)
                    realm.add(subscriptions, update: true)
                }, completion: completion)
            case .error(let error):
                switch error {
                case .version:
                    self.fetchRoomsFallback(updatedSince: updatedSince, realm: realm, completion: completion)
                default:
                    completion?()
                }
            }
        }
    }

    func fetchRoles(subscription: Subscription, realm: Realm? = Realm.current, completion: (() -> Void)? = nil) {
        let rid = subscription.rid
        let rolesRequest = RoomRolesRequest(roomName: subscription.name, subscriptionType: subscription.type)

        let currentRealm = realm

        api.fetch(rolesRequest) { result in
            switch result {
            case .resource(let resource):
                if let subscription = Subscription.find(rid: rid, realm: currentRealm) {
                    try? currentRealm?.write {
                        let subscriptionCopy = Subscription(value: subscription)

                        subscriptionCopy.usersRoles.removeAll()
                        resource.roomRoles?.forEach { role in
                            subscriptionCopy.usersRoles.append(role)
                        }

                        currentRealm?.add(subscriptionCopy, update: true)
                    }

                    completion?()
                }

            // Fail silently
            case .error(let error):
                print(error)
            }
        }
    }

    // fallback for servers < 0.60.0
    func fetchSubscriptionsFallback(updatedSince: Date?, realm: Realm? = Realm.current, completion: (() -> Void)?) {
        var params: [[String: Any]] = []

        if let updatedSince = updatedSince {
            params.append(["$date": Date.intervalFromDate(updatedSince)])
        }

        let requestSubscriptions = [
            "msg": "method",
            "method": "subscriptions/get",
            "params": params
        ] as [String: Any]

        let currentRealm = realm

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

                auth.lastSubscriptionFetchWithLastMessage = Date.serverDate

                realm.add(subscriptions, update: true)
                realm.add(auth, update: true)

                completion?()
            })
        }
    }

    // fallback for servers < 0.62.0
    func fetchRoomsFallback(updatedSince: Date?, realm: Realm? = Realm.current, completion: (() -> Void)?) {
        var params: [[String: Any]] = []

        if let updatedSince = updatedSince {
            params.append(["$date": Date.intervalFromDate(updatedSince)])
        }

        let requestRooms = [
            "msg": "method",
            "method": "rooms/get",
            "params": params
            ] as [String: Any]

        let currentRealm = Realm.current

        SocketManager.send(requestRooms) { response in
            guard !response.isError() else { return Log.debug(response.result.string) }

            currentRealm?.execute({ realm in
                guard let auth = AuthManager.isAuthenticated(realm: realm) else { return }
                auth.lastSubscriptionFetchWithLastMessage = Date.serverDate.addingTimeInterval(-1)
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
                            subscription.mapRoom(object, realm: realm)
                            subscriptions.append(subscription)
                        }
                    }
                }

                updated?.forEach { object in
                    if let rid = object["_id"].string {
                        if let subscription = Subscription.find(rid: rid, realm: realm) {
                            subscription.mapRoom(object, realm: realm)
                            subscriptions.append(subscription)
                        }
                    }
                }

                realm.add(subscriptions, update: true)
            }, completion: {
                completion?()
            })
        }
    }
}
