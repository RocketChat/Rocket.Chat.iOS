//
//  InfoRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/miscellaneous/info

typealias InfoResult = APIResult<InfoRequest>

class InfoRequest: APIRequest {
    static let path: String = "/api/v1/info"
}

extension APIResult where T == InfoRequest {
    var version: String? {
        return raw?["info"]["version"].string
    }
}
