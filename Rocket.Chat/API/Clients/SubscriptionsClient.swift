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
        api.fetch(req) { _ in }
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
            default:
                completion?()
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
            default:
                completion?()
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

}
