//
//  SubscriptionListRequest.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 25/10/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//  DOCS: https://docs.rocket.chat/developer-guides/rest-api/channels/list

import Foundation
import SwiftyJSON
import RealmSwift

enum SubscriptionListType {
    case channel
    case group

    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.list"
        case .group:
            return "/api/v1/groups.list"
        }
    }
}

class SubscriptionListRequest: APIRequest {
    let type: SubscriptionListType
    var path: String {
        return type.path
    }

    init(type: SubscriptionListType = .channel) {
        self.type = type
    }
}

extension APIResult where T == SubscriptionListRequest {
    var channels: [Subscription]? {
        guard let realm = Realm.shared else { return nil }

        return raw?["channels"].map {
            let json = $0.1

            let subscription = Subscription()
            subscription.map(json, realm: realm)

            return subscription
        }
    }
}
