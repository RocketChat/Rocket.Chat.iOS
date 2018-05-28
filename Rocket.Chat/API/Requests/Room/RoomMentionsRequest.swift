//
//  RoomMentionsRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 03/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import Foundation

final class RoomMentionsRequest: APIRequest {
    typealias APIResourceType = RoomMentionsResource

    let requiredVersion = Version(0, 63, 0)
    let path = "/api/v1/channels.getAllUserMentionsByChannel"

    let roomId: String?
    var query: String?

    init(roomId: String) {
        self.roomId = roomId
        self.query = "roomId=\(roomId)"
    }
}

final class RoomMentionsResource: APIResource {
    var messages: [Message]? {
        return raw?["mentions"].arrayValue.map {
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

    var errorMessage: String? {
        return raw?["error"].string
    }

    var success: Bool {
        return raw?["success"].bool ?? false
    }
}
