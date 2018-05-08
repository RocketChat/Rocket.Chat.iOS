//
//  SubscriptionsClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
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
                print(error)
                if case .version = error {
                    SubscriptionManager.markAsRead(subscription, completion: { _ in })
                }
            }
        }
    }

    func fetchSubscriptions(updatedSince: Date? = nil, realm: Realm? = Realm.current) {
        let req = SubscriptionsRequest(updatedSince: updatedSince)

        let currentRealm = realm

        api.fetch(req) { response in
            switch response {
            case .resource(let resource):
                guard resource.success == true else { return }

                let subscriptions = List<Subscription>()

                let updated = resource.raw?["result"]["update"].array
                let removed = resource.raw?["result"]["remove"].array

                currentRealm?.execute({ realm in
                    guard let auth = AuthManager.isAuthenticated(realm: realm) else { return }

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
                        // request rooms
                    }
                })
            case .error(let error):
                break
            }
        }
    }
}
