//
//  LoginServicesRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 04/04/18.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/miscellaneous/info

import SwiftyJSON

typealias LoginServicesResult = APIResult<LoginServicesRequest>

class LoginServicesRequest: APIRequest {
    let path = "/api/v1/settings.oauth"
}

extension APIResult where T == LoginServicesRequest {
    var loginServices: [LoginService] {
        return raw?["services"].arrayValue.map {
            let service = LoginService()
            service.map($0, realm: nil)
            return service
        } ?? []
    }
}
