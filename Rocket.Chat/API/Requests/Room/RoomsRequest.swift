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
    let requiredVersion = Version(0, 60, 0)

    var query: String? {
        if let updatedSince = updatedSince {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
            return "updatedSince=\(dateFormatter.string(from: updatedSince))"
        }

        return nil
    }

    let updatedSince: Date?

    init(updatedSince: Date? = nil) {
        self.updatedSince = updatedSince
    }
}

final class RoomsResource: APIResource {
    var update: [Subscription]? {
        return raw?["update"].arrayValue.map {
            let subscription = Subscription()
            subscription.map($0, realm: nil)
            return subscription
            }.compactMap { $0 }
    }

    var remove: [Subscription]? {
        return raw?["update"].arrayValue.map {
            let subscription = Subscription()
            subscription.map($0, realm: nil)
            return subscription
            }.compactMap { $0 }
    }

    var success: Bool? {
        return raw?["success"].bool
    }
}

