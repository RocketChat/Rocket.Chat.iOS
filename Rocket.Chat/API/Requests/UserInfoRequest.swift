//
//  UserInfoRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/users/info

import SwiftyJSON

typealias UserInfoResult = APIResult<UserInfoRequest>

class UserInfoRequest: APIRequest {
    static let path = "/api/v1/users.info"

    let query: String?

    let userId: String?
    let username: String?

    init(userId: String) {
        self.userId = userId
        self.username = nil
        self.query = "userId=\(userId)"
    }

    init(username: String) {
        self.username = username
        self.userId = nil
        self.query = "username=\(username)"
    }
}

extension APIResult where T == UserInfoRequest {
    var user: JSON? {
        return raw?["user"]
    }

    var id: String? {
        return user?["_id"].string
    }

    var type: String? {
        return user?["type"].string
    }

    var name: String? {
        return user?["name"].string
    }

    var username: String? {
        return user?["username"].string
    }
}
