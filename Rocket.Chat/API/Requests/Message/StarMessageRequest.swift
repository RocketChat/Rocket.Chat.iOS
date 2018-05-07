//
//  StarMessageRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 4/26/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

import SwiftyJSON

final class StarMessageRequest: APIRequest {
    typealias APIResourceType = StarMessageResource

    let requiredVersion = Version(0, 59, 0)

    let method: HTTPMethod = .post
    var path: String {
        return star ? "/api/v1/chat.starMessage" : "/api/v1/chat.unStarMessage"
    }

    let msgId: String
    let star: Bool

    init(msgId: String, star: Bool) {
        self.msgId = msgId
        self.star = star
    }

    func body() -> Data? {
        let body = JSON([
            "messageId": msgId
        ])

        return body.rawString()?.data(using: .utf8)
    }
}

final class StarMessageResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
