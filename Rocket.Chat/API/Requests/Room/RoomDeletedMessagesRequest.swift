//
//  RoomDeletedMessagesRequest.swift
//  Rocket.Chat
//
//  Created by Luís Machado on 29/03/2019.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

struct RoomDeletedMessagesRequest: APIRequest {
    typealias APIResourceType = RoomDeletedMessagesResource

    let path = "/api/v1/chat.getDeletedMessages"
    let requiredVersion = Version(1,1,0)

    var query: String?
    let roomId: String?
    let since: Date?

    init(roomId: String, since: Date) {
        self.roomId = roomId
        self.since = since

        let dateFormatter = ISO8601DateFormatter()
        let dateString = dateFormatter.string(from: since)

        if let encodedString = dateString.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.query = "roomId=\(roomId)&since=\(encodedString)"
        }
    }
}

final class RoomDeletedMessagesResource: APIResource {
    var messages: [String?]? {
        return raw?["messages"].arrayValue.map {
            if let removedMsg = $0.dictionaryObject, let msgId = removedMsg["_id"] as? String {
                return msgId
            }
            return nil
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
