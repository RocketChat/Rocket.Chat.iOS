//
//  RoomCreateRequest.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 28/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS:
//      https://rocket.chat/docs/developer-guides/rest-api/channels/create
//      https://rocket.chat/docs/developer-guides/rest-api/groups/create

import Foundation

enum RoomCreateType {
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

class RoomCreateRequest: APIRequest {
    let method: String = "POST"
    var path: String {
        return type.path
    }

    let roomName: String
    let type: RoomCreateType
    let readOnly: Bool

    init(roomName: String, type: RoomCreateType, readOnly: Bool = false) {
        self.roomName = roomName
        self.type = type
        self.readOnly = readOnly
    }

    func body() -> Data? {
        let json: [String: Any] = [
            "name": roomName,
            "readOnly": readOnly
        ]

        return try? JSONSerialization.data(withJSONObject: json)
    }

    var contentType: String? {
        return "application/json"
    }
}

extension APIResult where T == RoomCreateRequest {
}
