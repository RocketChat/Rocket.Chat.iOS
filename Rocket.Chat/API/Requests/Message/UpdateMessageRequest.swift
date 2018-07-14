//
//  UpdateMessageRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/7/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

final class UpdateMessageRequest: APIRequest {
    typealias APIResourceType = UpdateMessageResource

    let requiredVersion = Version(0, 49, 0)

    let method: HTTPMethod = .post
    let path = "/api/v1/chat.update"

    let roomId: String
    let msgId: String
    let text: String

    init(roomId: String, msgId: String, text: String) {
        self.roomId = roomId
        self.msgId = msgId
        self.text = text
    }

    func body() -> Data? {
        let body = JSON([
            "roomId": roomId,
            "msgId": msgId,
            "text": text
        ])

        return body.rawString()?.data(using: .utf8)
    }
}

final class UpdateMessageResource: APIResource {
    var message: Message? {
        guard let rawMessage = raw?["message"] else { return nil }

        let message = Message()
        message.map(rawMessage, realm: nil)
        return message
    }
}
