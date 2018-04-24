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

    init(id: String, roomId: String, text: String) {
        self.id = id
        self.roomId = roomId
        self.text = text
    }

    func body() -> Data? {
        let body = JSON([
            "message": [
                "_id": id,
                "rid": roomId,
                "msg": text
            ]
        ])

        return body.rawString()?.data(using: .utf8)
    }
}

final class SendMessageResource: APIResource {

}
