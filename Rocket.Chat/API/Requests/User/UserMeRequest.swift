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
        let user = User()
        user.identifier = userRaw?["_id"].string
        user.name = userRaw?["name"].string
        user.username = userRaw?["username"].string

        guard let emails = userRaw?["emails"].array else { return user }
        user.emails.append(contentsOf: emails.flatMap { (emailJSON) -> Email? in
            let email = Email(value: [
                "email": emailJSON["address"].stringValue,
                "verified": emailJSON["verified"].boolValue
                ])
            guard !email.email.isEmpty else { return nil }
            return email
        })

        return user
    }
}
