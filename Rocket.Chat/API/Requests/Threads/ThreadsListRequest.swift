//
//  ThreadsListRequest.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

// TODO: Add documentation link

import Foundation

final class ThreadsListRequest: APIRequest {
    typealias APIResourceType = ThreadsListResource

    let requiredVersion = Version(1, 0, 0)

    let method: HTTPMethod = .get
    var path = "/api/v1/chat.getThreadsList"

    var query: String?

    init(rid: String) {
        self.query = "rid=\(rid)"
    }

}

final class ThreadsListResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
