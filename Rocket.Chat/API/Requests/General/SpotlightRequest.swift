//
//  SpotlightRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 9/18/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/spotlight/

import SwiftyJSON

typealias SpotlightResult = APIResult<SpotlightRequest>

class SpotlightRequest: APIRequest {
    let version = Version(0, 61, 0)
    let path = "/api/v1/spotlight"

    let query: String?

    init(query: String) {
        self.query = "query=\(query)"
    }
}

extension APIResult where T == SpotlightRequest {
    var users: [JSON] {
        return raw?["users"].arrayValue ?? []
    }

    var rooms: [JSON] {
        return raw?["rooms"].arrayValue ?? []
    }

    var success: Bool {
        return raw?["success"].boolValue ?? false
    }

    var error: String {
        return raw?["error"].stringValue ?? ""
    }
}
