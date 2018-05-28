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
            self.identifier = values["_id"].stringValue
        }

        self.rid = values["rid"].stringValue
        self.name = values["name"].stringValue
        self.fname = values["fname"].stringValue
        self.unread = values["unread"].int ?? 0
        self.open = values["open"].bool ?? false
        self.alert = values["alert"].bool ?? false
        self.favorite = values["f"].bool ?? false

        if let typeString = values["t"].string {
            self.type = SubscriptionType(rawValue: typeString) ?? .channel
        }

        if self.type == .directMessage {
            if let userId = values["u"]["_id"].string {
                if let range = self.rid.ranges(of: userId).first {
                    self.otherUserId = self.rid.replacingCharacters(in: range, with: "")
                }
            }
        }

        if let createdAt = values["ts"]["$date"].double {
            self.createdAt = Date.dateFromInterval(createdAt)
        }

        if let lastSeen = values["ls"].string {
            self.lastSeen = Date.dateFromString(lastSeen)
        }

        if let lastSeen = values["ls"]["$date"].double {
            self.lastSeen = Date.dateFromInterval(lastSeen)
        }
    }

    func mapRoom(_ values: JSON, realm: Realm?) {
        self.roomDescription = values["description"].stringValue
        self.roomTopic = values["topic"].stringValue

        if let broadcast = values["broadcast"].bool {
            self.roomBroadcast = broadcast
        }

        if let readOnly = values["ro"].bool {
            self.roomReadOnly = readOnly
        }

        if let ownerId = values["u"]["_id"].string {
            self.roomOwnerId = ownerId
        }

        self.roomMuted.removeAll()
        if let roomMuted = values["muted"].array?.compactMap({ $0.string }) {
            self.roomMuted.append(objectsIn: roomMuted)
        }

        if let readOnly = values["ro"].bool {
            self.roomReadOnly = readOnly
        }

        if let ownerId = values["u"]["_id"].string {
            self.roomOwnerId = ownerId
        }

        if let updatedAt = values["_updatedAt"]["$date"].double {
            self.roomUpdatedAt = Date.dateFromInterval(updatedAt)
        }

        if values["lastMessage"].dictionary != nil {
            let message = Message()
            message.map(values["lastMessage"], realm: realm)
            message.subscription = self
            realm?.add(message, update: true)

            self.roomLastMessage = message

            if let createdAt = values["lastMessage"]["ts"].string {
                self.roomLastMessageDate = Date.dateFromString(createdAt)
            }

            if let createdAt = values["lastMessage"]["ts"]["$date"].double {
                self.roomLastMessageDate = Date.dateFromInterval(createdAt)
            }
        }
    }
}
