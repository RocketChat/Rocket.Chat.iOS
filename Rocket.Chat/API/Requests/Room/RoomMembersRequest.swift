//
//  RoomMembersRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/21/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import Foundation

fileprivate extension SubscriptionType {
    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.members"
        case .group:
            return "/api/v1/groups.members"
        case .directMessage:
            return "/api/v1/dm.members"
        }
    }
}

final class RoomMembersRequest: APIRequest {
    typealias APIResourceType = RoomMembersResource

    let requiredVersion = Version(0, 59, 0)

    var path: String {
        return type.path
    }

    var query: String?

    let roomId: String?
    let roomName: String?
    let type: SubscriptionType

    init(roomId: String, type: SubscriptionType = .channel) {
        self.type = type
        self.roomId = roomId
        self.roomName = nil
        self.query = "roomId=\(roomId)"
    }

    init(roomName: String, type: SubscriptionType = .channel) {
        self.type = type
        self.roomName = roomName
        self.roomId = nil
        self.query = "roomName=\(roomName)"
    }
}

class RoomMembersResource: APIResource {
    var members: [User?]? {
        return raw?["members"].arrayValue.map {
            let user = User()
            user.map($0, realm: nil)
            return user
        }
    }

    var count: Int? {
        return raw?["count"].int
    }

    var offset: Int? {
        return raw?["offset"].int
    }

    var total: Int? {
        return raw?["total"].int
    }
}
