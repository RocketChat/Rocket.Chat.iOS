//
//  MeRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/26/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/authentication/me

import SwiftyJSON

final class MeRequest: APIRequest {
    typealias APIResourceType = MeResource

    let path = "/api/v1/me"
}

final class MeResource: APIResource {
    var user: User? {
        guard let raw = raw else { return nil }

        let user = User()
        user.map(raw, realm: nil)
        return user
    }

    var errorMessage: String? {
        return raw?["error"].string
    }
}
