//
//  UserMeRequest.swift
//  Rocket.Chat
//
//  Created by Dennis Post on 25.11.17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

typealias UserMeResult = APIResult<UserMeRequest>

class UserMeRequest: APIRequest {
    let path = "/api/v1/me"
}

extension APIResult where T == UserMeRequest {
    var mee: JSON? {
        return raw
    }

    var user: User? {
        let updatingUser = User()
        updatingUser.name = name
        updatingUser.username = username

        guard let emails = emails else { return updatingUser }
        for dict in emails {
            let email = Email(value: ["email": dict.dictionaryValue["address"]?.stringValue, "verified": dict.dictionaryValue["verified"]?.intValue])
            updatingUser.emails.append(email)
        }

        return updatingUser
    }

    var id: String? {
        return mee?["_id"].string
    }

    var name: String? {
        return mee?["name"].string
    }

    var username: String? {
        return mee?["username"].string
    }

    var emails: [JSON]? {
        return mee?["emails"].array
    }
}
