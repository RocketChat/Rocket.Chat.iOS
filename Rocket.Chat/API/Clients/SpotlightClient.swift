//
//  SpotlightClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/28/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct SpotlightClient: APIClient {
    let api: AnyAPIFetcher
    init(api: AnyAPIFetcher) {
        self.api = api
    }

    func search(query: String, realm: Realm? = Realm.current, completion: @escaping RequestCompletion) {
        api.fetch(SpotlightRequest(query: query)) { response in
            switch response {
            case .resource(let resource):
                guard resource.success else {
                    completion(nil, true)
                    return
                }

                realm?.execute({ (realm) in
                    var subscriptions: [Subscription] = []

                    resource.rooms.forEach { object in
                        // Important note: On this API "_id" means "rid"
                        if let roomIdentifier = object["_id"].string {
                            if let subscription = Subscription.find(rid: roomIdentifier, realm: realm) {
                                subscription.map(object, realm: realm)
                                subscription.mapRoom(object, realm: realm)
                                subscriptions.append(subscription)
                            } else {
                                let subscription = Subscription()
                                subscription.identifier = roomIdentifier
                                subscription.rid = roomIdentifier
                                subscription.name = object["name"].string ?? ""

                                if let typeRaw = object["t"].string, let type = SubscriptionType(rawValue: typeRaw) {
                                    subscription.type = type
                                }

                                subscriptions.append(subscription)
                            }
                        }
                    }

                    resource.users.forEach { object in
                        let user = User.getOrCreate(realm: realm, values: object, updates: nil)

                        guard let username = user.username else {
                            return
                        }

                        let subscription = Subscription.find(name: username, subscriptionType: [.directMessage]) ?? Subscription()
                        if subscription.realm == nil {
                            subscription.identifier = subscription.identifier ?? user.identifier ?? ""
                            subscription.otherUserId = user.identifier
                            subscription.type = .directMessage
                            subscription.name = user.username ?? ""
                            subscription.fname = user.name ?? ""
                            subscriptions.append(subscription)
                        }
                    }

                    realm.add(subscriptions, update: true)
                }, completion: {
                    completion(resource.raw, false)
                })
            case .error:
                completion(nil, true)
            }
        }
    }
}
