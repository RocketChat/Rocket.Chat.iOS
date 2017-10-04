//
//  ChannelCreateRequest.swift
//  Rocket.Chat
//
//  Created by Bruno Macabeus Aquino on 28/09/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS:
//      https://rocket.chat/docs/developer-guides/rest-api/channels/create
//      https://rocket.chat/docs/developer-guides/rest-api/groups/create

import Foundation

enum ChannelCreateType {
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

class ChannelCreateRequest: APIRequest {
    let method: String = "POST"
    var path: String {
        return type.path
    }

    let channelName: String
    let type: ChannelCreateType

    init(channelName: String, type: ChannelCreateType) {
        self.channelName = channelName
        self.type = type
    }

    func body() -> Data? {
        let json: [String: Any] = [
            "name": channelName
        ]

        return try? JSONSerialization.data(withJSONObject: json)
    }

    var contentType: String? {
        return "application/json"
    }
}

extension APIResult where T == ChannelCreateRequest {
}
