//
//  InfoRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/miscellaneous/info

import SwiftyJSON

typealias InfoResult = APIResult<InfoRequest>

class InfoRequest: APIRequest {
    static let path: String = "/api/v1/info"
}

extension APIResult where T == InfoRequest {
    var info: JSON? {
        return raw?["info"]
    }

    var version: String? {
        return info?["version"].string
    }
}
