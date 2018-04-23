//
//  ReactMessageRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

import SwiftyJSON

final class ReactMessageRequest: APIRequest {
    typealias APIResourceType = ReactMessageResource

    let requiredVersion = Version(0, 62, 0)

    let method: HTTPMethod = .post
    let path = "/api/v1/chat.react"

    let msgId: String
    let emoji: String

    init(msgId: String, emoji: String) {
        self.msgId = msgId
        self.emoji = emoji
    }

    func body() -> Data? {
        let body = JSON([
            "messageId": msgId,
            "emoji": emoji
        ])

        return body.rawString()?.data(using: .utf8)
    }
}

final class ReactMessageResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
