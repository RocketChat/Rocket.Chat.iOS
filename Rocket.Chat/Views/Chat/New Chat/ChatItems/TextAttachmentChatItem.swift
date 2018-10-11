//
//  TextAttachmentChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 30/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController
import RealmSwift

struct TextAttachmentChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return TextAttachmentCell.identifier
    }

    var attachment: UnmanagedAttachment

    var differenceIdentifier: String {
        return attachment.identifier
    }

    func isContentEqual(to source: TextAttachmentChatItem) -> Bool {
        return attachment.collapsed == source.attachment.collapsed && attachment.fields == source.attachment.fields
    }

    func toggleAttachmentFields() {
        Realm.executeOnMainThread({ realm in
            if let attachment = realm.objects(Attachment.self).filter("identifier = '\(self.attachment.identifier)'").first {
                attachment.collapsed = !self.attachment.collapsed
                realm.add(attachment, update: true)
            }
        })
    }
}
