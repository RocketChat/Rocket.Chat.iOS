//
//  SubscriptionHideRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/07/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

fileprivate extension SubscriptionType {
    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.close"
        case .group:
            return "/api/v1/groups.close"
        case .directMessage:
            return "/api/v1/im.close"
        }
    }
}

final class SubscriptionHideRequest: APIRequest {
    typealias APIResourceType = SubscriptionHideResource

    let requiredVersion = Version(0, 48, 0)

    let method: HTTPMethod = .post
    var path: String {
        return type.path
    }

    let rid: String
    let type: SubscriptionType

    init(rid: String, subscriptionType: SubscriptionType) {
        self.rid = rid
        self.type = subscriptionType
    }

    func body() -> Data? {
        let body = JSON([
            "roomId": rid
        ])

        return body.rawString()?.data(using: .utf8)
    }
}

final class SubscriptionHideResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
