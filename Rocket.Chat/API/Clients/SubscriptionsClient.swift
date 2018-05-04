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
}
