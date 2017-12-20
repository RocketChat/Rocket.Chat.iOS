//
//  RegisterRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

typealias RegisterResult = APIResult<RegisterRequest>
typealias RegisterSucceeded = (RegisterResult) -> Void

class RegisterRequest: APIRequest {
    let version = Version(0, 50, 0)

    let method: HTTPMethod = .post
    let path = "/api/v1/users.register"

    let name: String
    let email: String
    let username: String
    let password: String
    let customFields: [String: String]

    init(name: String, email: String, username: String, password: String, customFields: [String: String] = [:]) {
        self.name = name
        self.email = email
        self.password = password
        self.username = username
        self.customFields = customFields
    }

    func body() -> Data? {
        let body = JSON([
            "name": name,
            "email": email,
            "username": username,
            "pass": password
        ].union(dictionary: customFields))

        return body.rawString()?.data(using: .utf8)
    }
}

extension APIResult where T == RegisterRequest {
    var error: String? {
        return raw?["error"].string
    }
}
