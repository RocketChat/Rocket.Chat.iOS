//
//  GetMessageRequest.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 10/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation

import SwiftyJSON

final class GetMessageRequest: APIRequest {
    typealias APIResourceType = GetMessageResource

    let requiredVersion = Version(0, 47, 0)

    let method: HTTPMethod = .get
    let path = "/api/v1/chat.getMessage"

    var query: String?

    init(msgId: String) {
        self.query = "msgId=\(msgId)"
    }
}

final class GetMessageResource: APIResource {
    var message: Message? {
        if let object = raw?["message"] {
            let message = Message()
            message.map(object, realm: nil)
            return message
        }

        return nil
    }

    var success: Bool {
        return raw?["success"].boolValue ?? false
    }
}
