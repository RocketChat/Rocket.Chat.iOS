//
//  SubscriptionModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

extension Subscription: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = values["_id"].string ?? ""
        }

        self.rid = values["rid"].string ?? ""
        self.name = values["name"].string ?? ""
        self.fname = values["fname"].string ?? ""
        self.unread = values["unread"].int ?? 0
        self.open = values["open"].bool ?? false
        self.alert = values["alert"].bool ?? false
        self.favorite = values["f"].bool ?? false

        if let typeString = values["t"].string {
            self.type = SubscriptionType(rawValue: typeString) ?? .channel
        }

        if self.type == .directMessage {
            let userId = values["u"]["_id"].string ?? ""
            self.otherUserId = self.rid.replacingOccurrences(of: userId, with: "")
        }

        if let createdAt = values["ts"]["$date"].double {
            self.createdAt = Date.dateFromInterval(createdAt)
        }

        if let lastSeen = values["ls"]["$date"].double {
            self.lastSeen = Date.dateFromInterval(lastSeen)
        }
    }

    func mapRoom(_ values: JSON) {
        self.roomDescription = values["description"].string ?? ""
        self.roomTopic = values["topic"].string ?? ""

        if let readOnly = values["ro"].bool {
            self.roomReadOnly = readOnly
        }

        if let ownerId = values["u"]["_id"].string {
            self.roomOwnerId = ownerId
        }

        if let updatedAt = values["_updatedAt"]["$date"].double {
            self.roomUpdatedAt = Date.dateFromInterval(updatedAt)
        }
    }
}
