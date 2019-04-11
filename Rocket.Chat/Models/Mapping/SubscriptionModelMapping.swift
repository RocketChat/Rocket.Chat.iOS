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

// swiftlint:disable cyclomatic_complexity
extension Subscription: ModelMappeable {
    func map(_ values: JSON, realm: Realm?) {
        if self.identifier == nil {
            self.identifier = values["_id"].stringValue
        }

        if let rid = values["rid"].string {
            self.rid = rid
        }

        if let prid = values["prid"].string {
            self.prid = prid
        }

        self.name = values["name"].stringValue

        if let fname = values["fname"].string {
            self.fname = fname
        } else {
            if self.fname.isEmpty {
                self.fname = self.name
            }
        }

        self.unread = values["unread"].int ?? 0
        self.userMentions = values["userMentions"].int ?? 0
        self.groupMentions = values["groupMentions"].int ?? 0
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

        self.usersCount = values["usersCount"].int ?? 0

        mapNotifications(values)
    }

    func mapNotifications(_ values: JSON) {
        self.disableNotifications = values["disableNotifications"].bool ?? false
        self.hideUnreadStatus = values["hideUnreadStatus"].bool ?? false

        if let desktopNotificationsString = values["desktopNotifications"].string {
            self.desktopNotifications = SubscriptionNotificationsStatus(rawValue: desktopNotificationsString) ?? .default
        }

        if let audioNotificationsString = values["audioNotifications"].string {
            self.audioNotifications = SubscriptionNotificationsStatus(rawValue: audioNotificationsString) ?? .default
        }

        if let mobilePushNotificationsString = values["mobilePushNotifications"].string {
            self.mobilePushNotifications = SubscriptionNotificationsStatus(rawValue: mobilePushNotificationsString) ?? .default
        }

        if let emailNotificationsString = values["emailNotifications"].string {
            self.emailNotifications = SubscriptionNotificationsStatus(rawValue: emailNotificationsString) ?? .default
        }

        if let audioNotificationValueString = values["audioNotificationValue"].string {
            self.audioNotificationValue = SubscriptionNotificationsAudioValue(rawValue: audioNotificationValueString) ?? .default
        }

        if let duration = values["desktopNotificationDuration"].int {
            self.desktopNotificationDuration = duration
        }
    }

    func mapRoom(_ values: JSON, realm: Realm?) {
        self.roomDescription = values["description"].stringValue
        self.roomAnnouncement = values["announcement"].stringValue
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
            if let userIdentifier = values["lastMessage"]["u"]["_id"].string {
                if let realm = realm {
                    if let user = realm.object(ofType: User.self, forPrimaryKey: userIdentifier as AnyObject) {
                        user.map(values["u"], realm: realm)
                        realm.add(user, update: true)
                    } else {
                        let user = User()
                        user.map(values["u"], realm: realm)
                        realm.add(user, update: true)
                    }
                }
            }

            let message = Message()
            message.map(values["lastMessage"], realm: realm)
            message.rid = rid

            if !(self.roomLastMessage == message) {
                realm?.add(message, update: true)

                self.roomLastMessage = message
                self.roomLastMessageText = Subscription.lastMessageText(lastMessage: message)

                if let createdAt = values["lastMessage"]["ts"].string {
                    self.roomLastMessageDate = Date.dateFromString(createdAt)
                }

                if let createdAt = values["lastMessage"]["ts"]["$date"].double {
                    self.roomLastMessageDate = Date.dateFromInterval(createdAt)
                }
            }
        } else {
            if self.roomLastMessageText?.isEmpty ?? true {
                self.roomLastMessageText = localized("subscriptions.list.no_message")
            }
        }
    }
}
