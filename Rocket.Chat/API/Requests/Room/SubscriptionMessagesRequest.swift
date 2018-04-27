//
//  RoomMessagesRequest.swift
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
            return "/api/v1/channels.messages"
        case .group:
            return "/api/v1/groups.messages"
        case .directMessage:
            return "/api/v1/dm.messages"
        }
    }
}

final class RoomMessagesRequest: APIRequest {
    typealias APIResourceType = RoomMessagesResource

    var path: String {
        return type.path
    }

    var query: String?

    let roomId: String?
    let roomName: String?
    let type: SubscriptionType

    init(roomId: String, type: SubscriptionType = .channel, query: String? = nil) {
        self.type = type
        self.roomId = roomId
        self.roomName = nil

        if let query = query {
            self.query = "roomId=\(roomId)&query=\(query)"
        } else {
            self.query = "roomId=\(roomId)"
        }
    }

    init(roomName: String, type: SubscriptionType = .channel) {
        self.type = type
        self.roomName = roomName
        self.roomId = nil

        if let query = query {
            self.query = "roomName=\(roomName)&query=\(query)"
        } else {
            self.query = "roomName=\(roomName)"
        }
    }
}

final class RoomMessagesResource: APIResource {
    var messages: [Message?]? {
        return raw?["messages"].arrayValue.map {
            let message = Message()
            message.map($0, realm: nil)
            return message
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
