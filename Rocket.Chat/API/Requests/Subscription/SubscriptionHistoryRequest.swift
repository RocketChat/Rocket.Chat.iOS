//
//  SubscriptionHistoryRequest.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 4/14/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import SwiftyJSON
import Foundation

fileprivate extension SubscriptionType {
    var path: String {
        switch self {
        case .channel:
            return "/api/v1/channels.history"
        case .group:
            return "/api/v1/groups.history"
        case .directMessage:
            return "/api/v1/dm.history"
        }
    }
}

fileprivate extension String {
    mutating func appendIfNotNil<T: CustomStringConvertible>(_ stringConvertible: T?, transform: ((T) -> String)?) {
        if let stringConvertible = stringConvertible {
            self += transform?(stringConvertible) ?? stringConvertible.description
        }
    }
}

class SubscriptionHistoryRequest: APIRequest {
    typealias APIResourceType = SubscriptionHistoryResource

    var path: String {
        return roomType.path
    }

    var query: String?

    let roomType: SubscriptionType
    let roomId: String?
    let latest: Date?
    let oldest: Date?
    let inclusive: Bool?
    let count: Int?
    let unreads: Bool?

    init(roomType: SubscriptionType, roomId: String,
         latest: Date? = nil, oldest: Date? = nil, inclusive: Bool? = nil, count: Int? = nil, unreads: Bool? = nil) {
        self.roomType = roomType
        self.roomId = roomId
        self.latest = latest
        self.oldest = oldest
        self.inclusive = inclusive
        self.count = count
        self.unreads = unreads

        var query = "roomId=\(roomId)"

        query.appendIfNotNil(latest) { "&latest=\($0.formatted(Date.apiDateFormat))" }
        query.appendIfNotNil(oldest) { "&oldest=\($0.formatted(Date.apiDateFormat))" }
        query.appendIfNotNil(inclusive) { "&inclusive=\($0)" }
        query.appendIfNotNil(count) { "&count=\($0)" }
        query.appendIfNotNil(unreads) { "&unreads=\($0)" }

        self.query = query
    }
}

class SubscriptionHistoryResource: APIResource {
    var success: Bool? {
        return raw?["success"].bool
    }
}
