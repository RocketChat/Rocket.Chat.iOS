//
//  LoginServicesRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 04/04/18.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/miscellaneous/info

import SwiftyJSON

class LoginServicesRequest: APIRequest {
    typealias APIResourceType = LoginServicesResource

    let requiredVersion: Version = Version(0, 64, 0)
    let path = "/api/v1/settings.oauth"
}

class LoginServicesResource: APIResource {
    var loginServices: [LoginService] {
        return raw?["services"].arrayValue.map {
            let service = LoginService()
            service.map($0, realm: nil)
            return service
        } ?? []
    }
}
