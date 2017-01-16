//
//  MessageModelMapping.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 16/01/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import SwiftyJSON
import RealmSwift

class MessageModelMapping: BaseModelMapping {
    typealias Model = Message

    func map(_ instance: Message, values: JSON) {
        if instance.identifier == nil {
            instance.identifier = values["_id"].string ?? ""
        }

        instance.rid = values["rid"].string ?? ""
        instance.text = values["msg"].string ?? ""

        if let createdAt = values["ts"]["$date"].double {
            instance.createdAt = Date.dateFromInterval(createdAt)
        }

        if let updatedAt = values["_updatedAt"]["$date"].double {
            instance.updatedAt = Date.dateFromInterval(updatedAt)
        }

        if let userId = values["u"]["_id"].string {
            instance.user = Realm.getOrCreate(User.self, primaryKey: userId, values: values["u"])
        }

        // Attachments
        if let attachments = values["attachments"].array {
            instance.attachments = List()

            for attachment in attachments {
                let obj = Attachment()
                obj.update(attachment)
                instance.attachments.append(obj)
            }
        }

        // URLs
        if let urls = values["urls"].array {
            instance.urls = List()

            for url in urls {
                let obj = MessageURL()
                obj.update(url)
                instance.urls.append(obj)
            }
        }
    }
}
