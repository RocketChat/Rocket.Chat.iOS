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

class Message: BaseModel {
    dynamic var subscription: Subscription!
    dynamic var rid = ""
    dynamic var createdAt: Date?
    dynamic var updatedAt: Date?
    dynamic var user: User?
    dynamic var text = ""

    dynamic var alias = ""
    dynamic var avatar = ""

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
}
