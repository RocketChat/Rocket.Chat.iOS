//
//  ChannelMembersRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/21/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import Foundation

typealias ChannelMembersResult = APIResult<ChannelMembersRequest>

class ChannelMembersRequest: APIRequest {
    static let path = "/api/v1/channels.members"

    let query: String?

    let roomId: String?
    let roomName: String?

    init(roomId: String) {
        self.roomId = roomId
        self.roomName = nil
        self.query = "roomId=\(roomId)"
    }

    init(roomName: String) {
        self.roomName = roomName
        self.roomId = nil
        self.query = "roomName=\(roomName)"
    }
}

extension APIResult where T == ChannelMembersRequest {
    var members: [API.User?]? {
        return raw?["members"].arrayValue.map {
            return API.User(json: $0)
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
