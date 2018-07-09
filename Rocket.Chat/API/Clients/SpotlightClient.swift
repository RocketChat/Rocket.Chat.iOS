//
//  SpotlightClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift
import SwiftyJSON

struct SpotlightClient: APIClient {
    let api: AnyAPIFetcher
    init(api: AnyAPIFetcher) {
        self.api = api
    }

    func search(query: String, realm: Realm? = Realm.current, completion: @escaping ([Subscription]) -> Void) {
        api.fetch(SpotlightRequest(query: query)) { response in
            switch response {
            case .resource(let resource):
                guard resource.success else {
                    completion([])
                    return Log.debug(resource.error)
                }

                var subscriptions = [Subscription]()
                var identifiers = [String]()

                realm?.execute({ (realm) in
                    let roomSubscriptions = SpotlightClient.parse(rooms: resource.rooms, realm: realm)
                    let userSubscriptions = SpotlightClient.parse(users: resource.users, realm: realm)

                    subscriptions = roomSubscriptions.subscriptions + userSubscriptions.subscriptions
                    identifiers = roomSubscriptions.identifiers + userSubscriptions.identifiers

                    realm.add(subscriptions, update: true)
                }, completion: {
                    var detachedSubscriptions = [Subscription]()

                    try? realm?.write {
                        for identifier in identifiers {
                            if let subscription = realm?.object(ofType: Subscription.self, forPrimaryKey: identifier) {
                                detachedSubscriptions.append(subscription)
                            }
                        }
                    }

                    completion(detachedSubscriptions)
                })
            case .error(let error):
                switch error {
                case .version:
                    SubscriptionManager.spotlight(query, completion: completion)
                default:
                    completion([])
                }
            }
        }
    }

    private struct Subscriptions {
        var subscriptions: [Subscription]
        var identifiers: [String]
    }

    private static func parse(rooms: [JSON], realm: Realm) -> Subscriptions {
        return rooms.reduce(Subscriptions(subscriptions: [], identifiers: [])) { (result, object) -> Subscriptions in
            let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                object?.rid = object?.identifier ?? ""
            })

            return Subscriptions(
                subscriptions: result.subscriptions + [subscription],
                identifiers: result.identifiers + [subscription.identifier].compactMap { $0 }
            )
        }
    }

    private static func parse(users: [JSON], realm: Realm) -> Subscriptions {
        return users.reduce(Subscriptions(subscriptions: [], identifiers: [])) { (result, object) -> Subscriptions in
            let user = User.getOrCreate(realm: realm, values: object, updates: nil)

            guard let username = user.username else {
                return result
            }

            let subscription = Subscription.find(name: username, subscriptionType: [.directMessage]) ?? Subscription()
            if subscription.realm == nil {
                subscription.identifier = subscription.identifier ?? user.identifier ?? ""
                subscription.otherUserId = user.identifier
                subscription.type = .directMessage
                subscription.name = user.username ?? ""
                subscription.fname = user.name ?? ""
            }

            return Subscriptions(
                subscriptions: result.subscriptions + [subscription].compactMap { $0.realm == nil ? $0 : nil },
                identifiers: result.identifiers + [subscription.identifier].compactMap { $0 }
            )
        }
    }
}
