//
//  PushTokenDeleteRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/8/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

typealias PushTokenDeleteResult = APIResult<PushTokenDeleteRequest>

class PushTokenDeleteRequest: APIRequest {
    let requiredVersion = Version(0, 60, 0)

    let method = "DELETE"
    let path = "/api/v1/push.token"

    let token: String

    init(token: String) {
        self.token = token
    }

    func body() -> Data? {
        return JSON(["token": token]).rawString()?.data(using: .utf8)
    }
}

extension APIResult where T == PushTokenDeleteRequest {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}

