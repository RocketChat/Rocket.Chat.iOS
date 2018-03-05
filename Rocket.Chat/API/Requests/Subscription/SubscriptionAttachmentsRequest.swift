//
//  SubscriptionAttachmentsRequest.swift
//  Rocket.Chat
//
//  Created by Hrayr Yeghiazaryan on 06.03.2018.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import Foundation

typealias SubscriptionAttachmentsResult = APIResult<SubscriptionAttachmentsRequest>

fileprivate extension SubscriptionType {
    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.files"
        case .group:
            return "/api/v1/groups.files"
        case .directMessage:
            return "/api/v1/dm.files"
        }
    }
}

class SubscriptionAttachmentsRequest: APIRequest {
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

extension APIResult where T == SubscriptionAttachmentsRequest {
    var messages: [Attachment?]? {
        return raw?["files"].arrayValue.map {
            let attachment = Attachment()
            attachment.map($0, realm: nil)
            return attachment
        }
    }
}
