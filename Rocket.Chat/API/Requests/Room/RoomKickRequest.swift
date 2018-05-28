//
//  RoomKickRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/18/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

fileprivate extension RoomType {
    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.kick"
        case .group:
            return "/api/v1/groups.kick"
        case .directMessage:
            return ""
        }
    }
}

final class RoomKickRequest: APIRequest {
    typealias APIResourceType = RoomKickResource
    let requiredVersion = Version(0, 48, 0)

    let method: HTTPMethod = .post
    var path: String {
        return roomType.path
    }

    let roomId: String
    let roomType: RoomType
    let userId: String

    init(roomId: String, roomType: RoomType, userId: String) {
        self.roomId = roomId
        self.roomType = roomType
        self.userId = userId
    }

    func body() -> Data? {
        let body = JSON([
            "roomId": roomId,
            "userId": userId
        ])

        return body.rawString()?.data(using: .utf8)
    }
}

final class RoomKickResource: APIResource, ResourceWithError {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
