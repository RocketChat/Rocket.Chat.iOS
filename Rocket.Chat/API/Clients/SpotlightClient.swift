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
                    resource.rooms.forEach { object in
                        let subscription = Subscription.getOrCreate(realm: realm, values: object, updates: { (object) in
                            object?.rid = object?.identifier ?? ""
                        })

                        if let identifier = subscription.identifier {
                            identifiers.append(identifier)
                        }

                        subscriptions.append(subscription)
                    }

                    resource.users.forEach { object in
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
}
