//
//  UserUpdateRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/02/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias UserUpdateResult = APIResult<UpdateUserRequest>

class UpdateUserRequest: APIRequest {
    let method: HTTPMethod = .post
    let path = "/api/v1/users.update"

    let userId: String
    let user: User?
    let password: String?

    init(userId: String, user: User? = nil, password: String? = nil) {
        self.userId = userId
        self.user = user
        self.password = password
    }

    func body() -> Data? {
        var body = JSON(["userId": userId, "data": [:]])

        if let user = user, let name = user.name, let username = user.username, let email = user.emails.first?.email,
                !name.isEmpty, !username.isEmpty, !email.isEmpty {
            body["data"]["name"].string = user.name
            body["data"]["username"].string = user.username
            body["data"]["email"].string = email
            body["data"]["verified"].bool = true
        }

        if let password = password, !password.isEmpty {
            body["data"]["password"].string = password
        }

        let string = body.rawString()
        let data = string?.data(using: .utf8)

        return data
    }

    var contentType: String? {
        return "application/json"
    }
}

extension APIResult where T == UpdateUserRequest {
    var user: User? {
        guard let rawMessage = raw?["user"] else { return nil }

        let user = User()
        user.map(rawMessage, realm: nil)
        return user
    }

    var success: Bool {
        return raw?["success"].boolValue ?? false
    }

    var errorMessage: String? {
        return raw?["error"].string
    }
}
