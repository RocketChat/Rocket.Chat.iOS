//
//  LoginRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/authentication/login

import SwiftyJSON

typealias LoginResult = APIResult<LoginRequest>

class LoginRequest: APIRequest {
    static let method: String = "POST"
    static let path = "/api/v1/login"

    let username: String
    let password: String

    init(_ username: String, _ password: String) {
        self.username = username
        self.password = password
    }

    func body() -> Data? {
        let string = """
        { "username": "\(username)", "password": "\(password)" }
        """

        return string.data(using: .utf8)
    }
}

extension APIResult where T == LoginRequest {
    var data: JSON? {
        return raw?["data"]
    }

    var authToken: String? {
        return data?["authToken"].string
    }

    var userId: String? {
        return data?["userId"].string
    }
}
