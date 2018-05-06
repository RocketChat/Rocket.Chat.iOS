//
//  LoginRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/authentication/login

import SwiftyJSON

typealias LoginParams = [String: Any]

final class LoginRequest: APIRequest {
    typealias APIResourceType = LoginResource
    let method: HTTPMethod = .post
    let path = "/api/v1/login"

    let params: LoginParams

    init(params: LoginParams) {
        self.params = params
    }

    func body() -> Data? {
        return JSON(params).description.data(using: .utf8)
    }
}

final class LoginResource: APIResource {
    var error: String? {
        return raw?["error"].string
    }

    var status: String? {
        return raw?["status"].string
    }

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

typealias LoginResponse = APIResponse<LoginResource>
