//
//  UserUpdateRequest.swift
//  Rocket.Chat
//
//  Created by Dennis Post on 25.11.17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/users/update

import SwiftyJSON

typealias UserUpdateResult = APIResult<UserUpdateRequest>
typealias UserPasswordUpdateResult = APIResult<UserPasswordUpdateRequest>

class UserUpdateRequest: APIRequest {
    let method: String = "POST"
    let path = "/api/v1/users.update"

    let userId: String
    let user: User

    init(userId: String, user: User) {
        self.userId = userId
        self.user = user
    }

    func body() -> Data? {

        guard let name = user.name, let username = user.username, let email = user.emails.first else {
            return nil
        }

        let body = JSON([
            "userId": userId,
            "data": [
                "name": name,
                "username": username,
                "email": email.email
                ]
            ])

        let string = body.rawString()
        let data = string?.data(using: .utf8)

        return data
    }

    var contentType: String? {
        return "application/json"
    }
}

class UserPasswordUpdateRequest: APIRequest {
    let method: String = "POST"
    let path = "/api/v1/users.update"

    let userId: String
    let password: String

    init(userId: String, password: String) {
        self.userId = userId
        self.password = password
    }

    func body() -> Data? {

        let body = JSON([
            "userId": userId,
            "data": [
                "password": password
            ]
            ])

        let string = body.rawString()
        let data = string?.data(using: .utf8)

        return data
    }

    var contentType: String? {
        return "application/json"
    }
}

extension APIResult where T == UserUpdateRequest {
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
        return raw?["error"].stringValue
    }
}

extension APIResult where T == UserPasswordUpdateRequest {
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
        return raw?["error"].stringValue
    }
}
