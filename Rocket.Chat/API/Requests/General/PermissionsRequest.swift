//
//  PermissionsRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON

class PermissionsRequest: APIRequest {
    typealias APIResourceType = PermissionsResource

    let requiredVersion: Version = Version(0, 66, 0)
    let path = "/api/v1/permissions.list"
}

class PermissionsResource: APIResource {
    var permissions: [Permission] {
        return raw?["permissions"].arrayValue.map {
            let permission = Permission()
            permission.map($0, realm: nil)
            return permission
        } ?? []
    }
}
