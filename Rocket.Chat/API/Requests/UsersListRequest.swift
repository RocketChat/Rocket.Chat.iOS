//
//  UsersListRequest.swift
//  Rocket.Chat
//
//  Created by Artur Rymarz on 12.11.2017.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

typealias UsersListResult = APIResult<UsersListRequest>

class UsersListRequest: APIRequest {
    let path = "/api/v1/users.list"
    var query: String?

    init(name: String) {
        self.query = "query={ \"username\": { \"$regex\": \"\(name)\" } }"
    }
}

extension APIResult where T == UsersListRequest {
    var users: [User?]? {
        return raw?["users"].arrayValue.map {
            let user = User()
            user.map($0, realm: nil)
            return user
        }
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
