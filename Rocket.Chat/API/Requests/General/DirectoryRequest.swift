//
//  DirectoryRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/21/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/miscellaneous/directory/

import SwiftyJSON

enum DirectoryRequestType: String {
    case users
    case channels
}

final class DirectoryRequest: APIRequest {
    typealias APIResourceType = DirectoryResource

    let version = Version(0, 64, 0)
    let path = "/api/v1/directory"

    let query: String?

    init(text: String, type: DirectoryRequestType) {
        self.query = "query={\"text\": \"\(text)\", \"type\": \"\(type)\"}"
    }
}

final class DirectoryResource: APIResource, PagedResource {
    var users: [User] {
        return raw?["result"].arrayValue.map {
            let user = User()
            user.map($0, realm: nil)
            return user
        } ?? []
    }
}
