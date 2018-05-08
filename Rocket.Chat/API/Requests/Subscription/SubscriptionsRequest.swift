//
//  SubscriptionsRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/8/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

struct SubscriptionsRequest: APIRequest {
    typealias APIResourceType = SubscriptionsResource
    let path = "/api/v1/subscriptions.get"
    let requiredVersion = Version(0, 60, 0)
}

final class SubscriptionsResource: APIResource {
    var update: [Subscription]? {
        return raw?["update"].arrayValue.map {
            let subscription = Subscription()
            subscription.map($0, realm: nil)
            return subscription
        }.compactMap { $0 }
    }

    var remove: [Subscription]? {
        return raw?["update"].arrayValue.map {
            let subscription = Subscription()
            subscription.map($0, realm: nil)
            return subscription
        }.compactMap { $0 }
    }
}
