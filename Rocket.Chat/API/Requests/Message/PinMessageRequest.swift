//
//  PinMessageRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

import SwiftyJSON

final class PinMessageRequest: APIRequest {
    typealias APIResourceType = PinMessageResource

    let requiredVersion = Version(0, 59, 0)

    let method: HTTPMethod = .post
    var path: String {
        return pin ? "/api/v1/chat.pinMessage" : "/api/v1/chat.unPinMessage"
    }

    let msgId: String
    let pin: Bool

    init(msgId: String, pin: Bool) {
        self.msgId = msgId
        self.pin = pin
    }

    func body() -> Data? {
        let body = JSON([
            "messageId": msgId
        ])

        return body.rawString()?.data(using: .utf8)
    }
}

final class PinMessageResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
