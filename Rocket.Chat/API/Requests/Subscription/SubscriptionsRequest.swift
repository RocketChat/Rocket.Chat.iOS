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

    var query: String? {
        if let updatedSince = updatedSince {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return "updatedSince=\(dateFormatter.string(from: updatedSince))"
        }

        return nil
    }

    let updatedSince: Date?

    init(updatedSince: Date? = nil) {
        self.updatedSince = updatedSince
    }
}

final class SubscriptionsResource: APIResource {
    var update: [Subscription]? {
        return raw?["update"].array?.map {
            let subscription = Subscription()
            subscription.map($0, realm: nil)
            return subscription
        }.compactMap { $0 }
    }

    var remove: [Subscription]? {
        return raw?["remove"].array?.map {
            let subscription = Subscription()
            subscription.map($0, realm: nil)
            return subscription
        }.compactMap { $0 }
    }

    var list: [Subscription]? {
        return raw?["result"].array?.map {
            let subscription = Subscription()
            subscription.map($0, realm: nil)
            return subscription
        }.compactMap { $0 }
    }

    var success: Bool? {
        return raw?["success"].bool
    }
}
