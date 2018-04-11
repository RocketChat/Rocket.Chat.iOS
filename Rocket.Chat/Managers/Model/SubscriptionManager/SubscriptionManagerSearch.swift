//
//  SubscriptionManager+Search.swift
//  Rocket.Chat
//
//  Created by Samar Sunkaria on 4/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

extension SubscriptionManager {
    static func spotlight(_ text: String, completion: @escaping MessageCompletionObjectsList<Subscription>) {
        let request = [
            "msg": "method",
            "method": "spotlight",
            "params": [text, NSNull(), ["rooms": true, "users": true]]
            ] as [String: Any]

        let currentRealm = Realm.current
        SocketManager.send(request) { response in
            guard !response.isError() else {
                completion([])
                return Log.debug(response.result.string)
            }

            var subscriptions = [Subscription]()
            var identifiers = [String]()
            let rooms = response.result["result"]["rooms"].array
            let users = response.result["result"]["users"].array

            currentRealm?.execute({ (realm) in
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
                    subscription.fname = user.name ?? ""
                    subscriptions.append(subscription)

                    if let identifier = subscription.identifier {
                        identifiers.append(identifier)
                    }
                }

                realm.add(subscriptions, update: true)
            }, completion: {
                var detachedSubscriptions = [Subscription]()

                Realm.executeOnMainThread(realm: currentRealm, { (realm) in
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
}
