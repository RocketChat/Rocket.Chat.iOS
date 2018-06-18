//
//  RoomsRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/8/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

struct RoomsRequest: APIRequest {
    typealias APIResourceType = RoomsResource
    let path = "/api/v1/rooms.get"
    let requiredVersion = Version(0, 62, 0)
}

final class RoomsResource: APIResource {
    var update: [JSON]? {
        return raw?["update"].array
    }

    var remove: [JSON]? {
        return raw?["remove"].array
    }

    var list: [JSON]? {
        return raw?["result"].array
    }

    var success: Bool? {
        return raw?["success"].bool
    }
}
