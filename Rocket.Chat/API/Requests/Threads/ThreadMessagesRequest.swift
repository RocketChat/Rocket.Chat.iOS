//
//  ThreadMessagesRequest.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

// DOCS: https://rocket.chat/docs/developer-guides/rest-api/chat/getthreadmessages/

import Foundation

final class ThreadMessagesRequest: APIRequest {
    typealias APIResourceType = ThreadMessagesResource

    let requiredVersion = Version(1, 0, 0)

    let method: HTTPMethod = .get
    var path = "/api/v1/chat.getThreadMessages"

    var query: String?

    init(tmid: String) {
        self.query = "tmid=\(tmid)"
    }

}

final class ThreadMessagesResource: APIResource {
    var messages: [UnmanagedMessage] {
        return raw?["messages"].arrayValue.compactMap {
            let message = Message()
            message.map($0, realm: nil)
            return message.unmanaged
        } ?? []
    }

    var success: Bool? {
        return raw?["success"].boolValue
    }

    var count: Int? {
        return raw?["count"].int
    }

    var offset: Int? {
        return raw?["offset"].int
    }

    var total: Int? {
        return raw?["total"].int
    }
}
