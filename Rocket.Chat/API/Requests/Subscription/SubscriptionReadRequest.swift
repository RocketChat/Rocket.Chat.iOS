//
//  SubscriptionReadRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/3/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

import SwiftyJSON

final class SubscriptionReadRequest: APIRequest {
    typealias APIResourceType = SubscriptionReadResource

    let requiredVersion = Version(0, 61, 0)

    let method: HTTPMethod = .post
    let path = "/api/v1/subscriptions.read"

    let rid: String

    init(rid: String) {
        self.rid = rid
    }

    func body() -> Data? {
        let body = JSON([
            "rid": rid
        ])

        return body.rawString()?.data(using: .utf8)
    }
}

final class SubscriptionReadResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
