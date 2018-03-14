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
    let requiredVersion = Version(0, 62, 2)
    let method: HTTPMethod = .post
    let path = "/api/v1/users.updateOwnBasicInfo"

    let user: User?
    let currentPassword: String?
    let password: String?

    init(user: User? = nil, password: String? = nil, currentPassword: String? = nil) {
        self.user = user
        self.password = password
        self.currentPassword = currentPassword
    }

    func body() -> Data? {
        var body = JSON(["data": [:]])

        if let user = user, let name = user.name, let username = user.username, let email = user.emails.first?.email,
                !name.isEmpty, !username.isEmpty, !email.isEmpty {
            body["data"]["name"].string = user.name
            body["data"]["username"].string = user.username
            body["data"]["email"].string = email
        }

        if let password = password, !password.isEmpty {
            body["data"]["password"].string = password
        }

        if !(body["data"]["email"].string?.isEmpty ?? true) || !(password?.isEmpty ?? true) {
            guard let sha256password = currentPassword?.sha256() else { return nil }
            body["data"]["currentPassword"].string = sha256password
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
