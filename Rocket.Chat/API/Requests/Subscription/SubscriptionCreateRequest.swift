//
//  SubscriptionCreateRequest.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 28/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS:
//      https://rocket.chat/docs/developer-guides/rest-api/channels/create
//      https://rocket.chat/docs/developer-guides/rest-api/groups/create

import Foundation

enum SubscriptionCreateType {
    case channel
    case group

    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.create"
        case .group:
            return "/api/v1/groups.create"
        }
    }
}

class SubscriptionCreateRequest: APIRequest {
    let method: String = "POST"
    var path: String {
        return type.path
    }

    let name: String
    let type: SubscriptionCreateType
    let readOnly: Bool

    init(name: String, type: SubscriptionCreateType, readOnly: Bool = false) {
        self.name = name
        self.type = type
        self.readOnly = readOnly
    }

    func body() -> Data? {
        let json: [String: Any] = [
            "name": name,
            "readOnly": readOnly
        ]

        return try? JSONSerialization.data(withJSONObject: json)
    }

    var contentType: String? {
        return "application/json"
    }
}

extension APIResult where T == SubscriptionCreateRequest {
    var success: Bool? {
        return raw?["success"].boolValue
    }

    var error: String? {
        return raw?["error"].string
    }
}
