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

extension Message: ModelMappeable {
    func map(_ values: JSON) {
        if self.identifier == nil {
            self.identifier = values["_id"].string ?? ""
        }

        self.rid = values["rid"].string ?? ""
        self.text = values["msg"].string ?? ""
        self.avatar = values["avatar"].string ?? ""
        self.alias = values["alias"].string ?? ""
        self.internalType = values["t"].string ?? "t"
        self.role = values["role"].string ?? ""
        self.pinned = values["pinned"].bool ?? false

        if let createdAt = values["ts"]["$date"].double {
            self.createdAt = Date.dateFromInterval(createdAt)
        }

        if let updatedAt = values["_updatedAt"]["$date"].double {
            self.updatedAt = Date.dateFromInterval(updatedAt)
        }

        if let userIdentifier = values["u"]["_id"].string {
            self.user = User.getOrCreate(values: values["u"], updates: nil)

            var isBlocked = false
            for blocked in MessageManager.blockedUsersList {
                if blocked == userIdentifier {
                    isBlocked = true
                }
            }

            self.userBlocked = isBlocked
        }

        // Attachments
        if let attachments = values["attachments"].array {
            self.attachments = List()

            for attachment in attachments {
                let obj = Attachment()
                obj.map(attachment)
                self.attachments.append(obj)
            }
        }

        // URLs
        if let urls = values["urls"].array {
            self.urls = List()

            for url in urls {
                let obj = MessageURL()
                obj.map(url)
                self.urls.append(obj)
            }
        }
    }
}
