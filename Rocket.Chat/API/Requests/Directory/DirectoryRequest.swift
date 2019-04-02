//
//  DirectoryRequest.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 08/02/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//
//  DOCS: https://rocket.chat/docs/developer-guides/rest-api/miscellaneous/directory/

import SwiftyJSON

enum DirectoryRequestType: String {
    case users
    case channels
}

enum DirectoryWorkspaceType: String {
    case local
    case all
}

final class DirectoryRequest: APIRequest {
    typealias APIResourceType = DirectoryResource

    let version = Version(0, 65, 0)
    let path = "/api/v1/directory"

    let query: String?

    init(query: String, type: DirectoryRequestType, workspace: DirectoryWorkspaceType) {
        let sort = type == .channels ? "sort={\"usersCount\":-1}&" : "sort={\"username\":1}&"

        if let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
            self.query = "\(sort)query={\"text\": \"\(encodedQuery)\", \"type\": \"\(type)\", \"workspace\": \"\(workspace)\"}"
        } else {
            self.query = "\(sort)query={\"type\": \"\(type)\", \"workspace\": \"\(workspace)\"}"
        }
    }
}

/*
 Careful when using the results of DirectoryResource, because the
 API can return different type of objects inside the same array
 called "results". When getting the results, you will need to
 make sure you're trying to access the correct property.
 */
final class DirectoryResource: APIResource {
    var users: [UnmanagedUser] {
        return raw?["result"].arrayValue.compactMap {
            let user = User()
            user.map($0, realm: nil)
            return user.unmanaged
        } ?? []
    }

    var channels: [UnmanagedSubscription] {
        return raw?["result"].arrayValue.compactMap {
            let subscription = Subscription()
            subscription.map($0, realm: nil)
            subscription.mapRoom($0, realm: nil)
            return subscription.unmanaged
        } ?? []
    }

    var count: Int? {
        return raw?["count"].int
    }

    var offset: Int? {
        return raw?["offset"].int
    }

    var total: Int? {
        return raw?["total"].int
    }
}
