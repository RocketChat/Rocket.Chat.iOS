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

final class TextAttachmentChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return hasText ? TextAttachmentCell.identifier : TextAttachmentMessageCell.identifier
    }

    var attachment: UnmanagedAttachment
    let hasText: Bool

    init(attachment: UnmanagedAttachment, hasText: Bool, user: UnmanagedUser?, message: UnmanagedMessage?) {
        self.attachment = attachment
        self.hasText = hasText
        super.init(user: user, avatar: message?.avatar, emoji: message?.emoji, date: message?.createdAt, isUnread: message?.unread ?? false)
    }

    var differenceIdentifier: String {
        return attachment.identifier
    }

    func isContentEqual(to source: TextAttachmentChatItem) -> Bool {
        return attachment.collapsed == source.attachment.collapsed && attachment.fields == source.attachment.fields
    }

    func toggleAttachmentFields() {
        let filter = "identifier = '\(self.attachment.identifier)'"

        Realm.executeOnMainThread({ realm in
            if let attachment = realm.objects(Attachment.self).filter(filter).first {
                attachment.collapsed = !self.attachment.collapsed
                realm.add(attachment, update: true)
            }
        })
    }
}
