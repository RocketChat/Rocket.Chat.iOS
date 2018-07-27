//
//  SubscriptionLeaveRequest.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 27/07/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

fileprivate extension SubscriptionType {
    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.leave"
        case .group:
            return "/api/v1/groups.leave"
        default:
            return "/api/v1/channels.leave"
        }
    }
}

final class SubscriptionLeaveRequest: APIRequest {
    typealias APIResourceType = SubscriptionLeaveResource

    var path: String {
        return type.path
    }

    var query: String?
    let roomId: String?
    let type: SubscriptionType

    init(roomId: String, type: SubscriptionType = .channel) {
        self.type = type
        self.roomId = roomId
        self.query = "roomId=\(roomId)"
    }
}

final class SubscriptionLeaveResource: APIResource {
    var success: Bool? {
        return raw?["success"].boolValue
    }
}
