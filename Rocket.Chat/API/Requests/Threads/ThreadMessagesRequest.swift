//
//  ThreadMessagesRequest.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

// TODO: Add documentation link

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
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
