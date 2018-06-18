//
//  RoomFilesRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 11/04/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import Foundation
import RealmSwift

fileprivate extension SubscriptionType {
    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.files"
        case .group:
            return "/api/v1/groups.files"
        case .directMessage:
            return "/api/v1/dm.files"
        }
    }
}

final class RoomFilesRequest: APIRequest {
    typealias APIResourceType = RoomFilesResource

    var path: String {
        return type.path
    }

    var query: String?
    let roomId: String?
    let type: SubscriptionType

    init(roomId: String, subscriptionType: SubscriptionType) {
        self.type = subscriptionType
        self.roomId = roomId
        self.query = "roomId=\(roomId)&sort={\"uploadedAt\":-1}"
    }
}

final class RoomFilesResource: APIResource {
    var files: [File]? {
        let realm = Realm.current
        return raw?["files"].arrayValue.map {
            let file = File()
            file.map($0, realm: realm)
            return file
        }
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

    var success: Bool {
        return raw?["success"].bool ?? false
    }
}
