//
//  ThreadFollowRequest.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

// TODO: Add documentation link

import Foundation

final class ThreadFollowRequest: APIRequest {
    typealias APIResourceType = ThreadFollowResource

    let requiredVersion = Version(1, 0, 0)

    let method: HTTPMethod = .get
    var path = "/api/v1/chat.followMessage"

    var query: String?

    init(mid: String) {
        self.query = "mid=\(mid)"
    }

}

final class ThreadFollowResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
