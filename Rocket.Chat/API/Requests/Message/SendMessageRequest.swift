//
//  SendMessageRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/7/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

final class SendMessageRequest: APIRequest {
    typealias APIResourceType = SendMessageResource
    let requiredVersion = Version(0, 60, 0)

    let method: HTTPMethod = .post
    let path = "/api/v1/chat.sendMessage"

    let id: String
    let roomId: String
    let text: String
    let messageType: String?
    let threadIdentifier: String?

    init(id: String, roomId: String, text: String, threadIdentifier: String? = nil, messageType: String? = nil) {
        self.id = id
        self.roomId = roomId
        self.text = text
        self.messageType = messageType
        self.threadIdentifier = threadIdentifier
    }

    func body() -> Data? {
        var body = JSON([
            "message": [
                "_id": id,
                "rid": roomId,
                "msg": text
            ]
        ])

        if let threadIdentifier = threadIdentifier {
            body["message"]["tmid"] = JSON(threadIdentifier)
        }

        if let messageType = messageType {
            body["message"]["t"] = JSON(messageType)

            // Hacky way to work with Jitsi for web clients
            // this really needs a better way.
            if messageType == "jitsi_call_started" {
                body["message"]["actionLinks"] = [[
                    "icon": "icon-videocam",
                    "label": localized("chat.message.actions.join_video_call"),
                    "method_id": "joinJitsiCall",
                    "params": ""
                ]]
            }
        }

        return body.rawString()?.data(using: .utf8)
    }
}

final class SendMessageResource: APIResource {

}
