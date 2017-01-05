//
//  Message.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/14/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift
import SwiftyJSON

enum MessageType {
    case text
    case image
    case audio
    case video
    case url
}

final class Message: BaseModel {
    dynamic var subscription: Subscription!

    dynamic var rid = ""
    dynamic var createdAt: Date?
    dynamic var updatedAt: Date?
    dynamic var user: User?

    dynamic var text = ""

    var mentions = List<Mention>()
    var attachments = List<Attachment>()
    var urls = List<MessageURL>()

    var type: MessageType {
        if let attachment = attachments.first {
            return attachment.type
        }

        if let url = urls.first {
            if url.isValid() {
                return .url
            }
        }

        return .text
    }

    // MARK: ModelMapping

    override func update(_ dict: JSON) {
        if self.identifier == nil {
            self.identifier = dict["_id"].string ?? ""
        }

        self.rid = dict["rid"].string ?? ""
        self.text = dict["msg"].string ?? ""

        if let createdAt = dict["ts"]["$date"].double {
            self.createdAt = Date.dateFromInterval(createdAt)
        }

        if let updatedAt = dict["_updatedAt"]["$date"].double {
            self.updatedAt = Date.dateFromInterval(updatedAt)
        }

        if let userId = dict["u"]["_id"].string {
            self.user = Realm.getOrCreate(User.self, primaryKey: userId, values: dict["u"])
        }

        // Attachments
        if let attachments = dict["attachments"].array {
            self.attachments = List()

            for attachment in attachments {
                let obj = Attachment()
                obj.update(attachment)
                self.attachments.append(obj)
            }
        }

        // URLs
        if let urls = dict["urls"].array {
            self.urls = List()

            for url in urls {
                let obj = MessageURL()
                obj.update(url)
                self.urls.append(obj)
            }
        }
    }
}
