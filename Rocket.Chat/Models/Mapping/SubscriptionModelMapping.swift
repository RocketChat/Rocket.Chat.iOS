//
//  SubscriptionModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON

class SubscriptionModelMapping: BaseModelMapping {
    typealias Model = Subscription

    func map(_ instance: Subscription, values: JSON) {
        if instance.identifier == nil {
            instance.identifier = values["_id"].string ?? ""
        }

        instance.rid = values["rid"].string ?? ""
        instance.name = values["name"].string ?? ""
        instance.unread = values["unread"].int ?? 0
        instance.open = values["open"].bool ?? false
        instance.alert = values["alert"].bool ?? false
        instance.favorite = values["f"].bool ?? false

        if let typeString = values["t"].string {
            instance.type = SubscriptionType(rawValue: typeString) ?? .channel
        }

        if instance.type == .directMessage {
            let userId = values["u"]["_id"].string ?? ""
            instance.otherUserId = instance.rid.replacingOccurrences(of: userId, with: "")
        }

        if let createdAt = values["ts"]["$date"].double {
            instance.createdAt = Date.dateFromInterval(createdAt)
        }

        if let lastSeen = values["ls"]["$date"].double {
            instance.lastSeen = Date.dateFromInterval(lastSeen)
        }
    }
}
