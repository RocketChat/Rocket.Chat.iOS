//
//  InfoRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/miscellaneous/info

import SwiftyJSON

final class InfoRequest: APIRequest {
    typealias APIResourceType = InfoResource

    let path = "/api/v1/info"
}

final class InfoResource: APIResource {
    var version: String? {
        return raw?["info"]["version"].string
    }
}
