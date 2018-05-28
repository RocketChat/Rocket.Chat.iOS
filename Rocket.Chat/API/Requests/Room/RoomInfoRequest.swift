//
//  RoomInfoRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/channels/info

import SwiftyJSON

fileprivate extension SubscriptionType {
    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.info"
        case .group:
            return "/api/v1/groups.info"
        case .directMessage:
            return "/api/v1/dm.info"
        }
    }
}

final class RoomInfoRequest: APIRequest {
    typealias APIResourceType = RoomInfoResource

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

final class RoomInfoResource: APIResource {
    var channel: JSON? {
        return raw?["channel"]
    }

    var usernames: [String]? {
        return channel?["usernames"].arrayValue.map { $0.stringValue }
    }
}
