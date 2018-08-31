//
//  SubscriptionUnreadRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 26/07/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

final class SubscriptionUnreadRequest: APIRequest {
    typealias APIResourceType = SubscriptionUnreadResource

    let requiredVersion = Version(0, 65, 0)

    let method: HTTPMethod = .post
    let path = "/api/v1/subscriptions.unread"

    let rid: String

    init(rid: String) {
        self.rid = rid
    }

    func body() -> Data? {
        let body = JSON([
            "roomId": rid
        ])

        return body.rawString()?.data(using: .utf8)
    }
}

final class SubscriptionUnreadResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
