//
//  SubscriptionRolesRequest.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 11/05/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import RealmSwift

fileprivate extension SubscriptionType {
    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.roles"
        case .group:
            return "/api/v1/groups.roles"
        case .directMessage:
            return ""
        }
    }
}

final class SubscriptionRolesRequest: APIRequest {
    typealias APIResourceType = SubscriptionRolesResource

    var path: String {
        return type.path
    }

    var query: String?
    let roomName: String?
    let type: SubscriptionType

    init(roomName: String, subscriptionType: SubscriptionType) {
        self.type = subscriptionType
        self.roomName = roomName
        self.query = "roomName=\(roomName)"
    }
}

final class SubscriptionRolesResource: APIResource {
    var subscriptionRoles: [SubscriptionRoles]? {
        return raw?["roles"].arrayValue.map {
            var object = SubscriptionRoles()
            object.user = User.find(withIdentifier: $0["u"]["_id"].stringValue)
            object.roles.append(contentsOf: $0["roles"].arrayValue.compactMap({ $0.string }))
            return object
        }
    }

    var success: Bool {
        return raw?["success"].bool ?? false
    }
}
