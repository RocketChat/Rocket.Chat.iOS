//
//  UserMeRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 28/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

typealias UserMeResult = APIResult<UserMeRequest>

class UserMeRequest: APIRequest {
    let path = "/api/v1/me"
}

extension APIResult where T == UserMeRequest {
    var userRaw: JSON? {
        return raw
    }

    var user: User? {
        guard let raw = userRaw else { return nil }
        let user = User()
        user.map(raw, realm: nil)

        return user
    }
}
