//
//  PostMessageRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://docs.rocket.chat/developer-guides/rest-api/chat/postmessage

import SwiftyJSON

typealias PostMessageResult = APIResult<PostMessageRequest>

class PostMessageRequest: APIRequest {
    let method: String = "POST"
    let path = "/api/v1/chat.postMessage"

    let roomId: String
    let text: String

    init(roomId: String, text: String) {
        self.roomId = roomId
        self.text = text
    }

    func body() -> Data? {
        let body = JSON([
            "roomId": roomId,
            "text": text
        ])

        return body.rawString()?.data(using: .utf8)
    }

    var contentType: String? {
        return "application/json"
    }
}

extension APIResult where T == PostMessageRequest {
    var message: Message? {
        guard let rawMessage = raw?["message"] else { return nil }

        let message = Message()
        message.map(rawMessage, realm: nil)
        return message
    }
}
