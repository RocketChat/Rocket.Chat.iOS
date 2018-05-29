//
//  RoomRolesRequest.swift
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

final class RoomRolesRequest: APIRequest {
    typealias APIResourceType = RoomRolesResource

    let requiredVersion = Version(0, 64, 2)

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

final class RoomRolesResource: APIResource {
    var roomRoles: [RoomRoles]? {
        guard let realm = Realm.current else { return nil }
        return raw?["roles"].arrayValue.map {
            let object = RoomRoles()
            object.user = User.getOrCreate(realm: realm, values: $0["u"], updates: nil)
            object.roles.append(contentsOf: $0["roles"].arrayValue.compactMap({ $0.string }))
            return object
        }
    }

    var success: Bool {
        return raw?["success"].bool ?? false
    }
}
