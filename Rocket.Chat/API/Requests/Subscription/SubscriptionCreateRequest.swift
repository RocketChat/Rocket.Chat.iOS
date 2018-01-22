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
    let method: HTTPMethod = .post
    var path: String {
        return type.path
    }

    let name: String
    let type: SubscriptionCreateType
    let members: [String]
    let readOnly: Bool

    init(name: String, type: SubscriptionCreateType, members: [String] = [], readOnly: Bool = false) {
        self.name = name
        self.type = type
        self.members = members
        self.readOnly = readOnly
    }

    func body() -> Data? {
        let json: [String: Any] = [
            "name": name,
            "members": members,
            "readOnly": readOnly
        ]

        return try? JSONSerialization.data(withJSONObject: json)
    }
}

extension APIResult where T == SubscriptionCreateRequest {
    var success: Bool? {
        return raw?["success"].boolValue
    }

    var error: String? {
        return raw?["error"].string
    }

    var name: String? {
        guard let group = raw?["group"], group["t"] == "p" else {
            return raw?["channel"]["name"].string
        }
        return raw?["group"]["name"].string
    }
}
