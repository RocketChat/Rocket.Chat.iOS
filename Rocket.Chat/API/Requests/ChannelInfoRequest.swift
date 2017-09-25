//
//  ChannelInfoRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/channels/info

import SwiftyJSON

typealias ChannelInfoResult = APIResult<ChannelInfoRequest>

class ChannelInfoRequest: APIRequest {
    static let path = "/api/v1/channels.info"

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

extension APIResult where T == ChannelInfoRequest {
    var channel: JSON? {
        return raw?["channel"]
    }

    var usernames: [String]? {
        return channel?["usernames"].arrayValue.map { $0.stringValue }
    }
}
