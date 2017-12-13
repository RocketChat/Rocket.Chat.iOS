//
//  RegisterRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/13/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

typealias RegisterResult = APIResult<RegisterRequest>

class RegisterRequest: APIRequest {
    let method: String = "POST"
    let path = "/api/v1/users.register"

    let name: String
    let email: String
    let password: String
    let customFields: [String: String]
    let username: String?

    init(name: String, email: String, password: String, username: String? = nil, customFields: [String: String] = [:]) {
        self.name = name
        self.email = email
        self.password = password
        self.username = username
        self.customFields = customFields
    }

    func body() -> Data? {
        var body = JSON([
            "name": name,
            "email": email,
            "password": password,
        ].union(dictionary: customFields))

        username.flatMap { body["username"] = JSON($0) }

        return body.rawString()?.data(using: .utf8)
    }
}

extension APIResult where T == RegisterRequest {

}
