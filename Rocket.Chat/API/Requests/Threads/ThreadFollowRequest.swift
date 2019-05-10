//
//  ThreadFollowRequest.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

// DOCS: https://rocket.chat/docs/developer-guides/rest-api/chat/followmessage/

import Foundation
import SwiftyJSON

final class ThreadFollowRequest: APIRequest {
    typealias APIResourceType = ThreadFollowResource

    let requiredVersion = Version(1, 0, 0)

    let method: HTTPMethod = .post
    var path = "/api/v1/chat.followMessage"

    let mid: String

    init(mid: String) {
        self.mid = mid
    }

    func body() -> Data? {
        return JSON(["mid": mid]).rawString()?.data(using: .utf8)
    }

}

final class ThreadFollowResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
