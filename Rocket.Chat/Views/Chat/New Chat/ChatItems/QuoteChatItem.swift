//
//  QuoteChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 03/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController
import RealmSwift

final class QuoteChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return hasText ? QuoteCell.identifier : QuoteMessageCell.identifier
    }

    var attachment: UnmanagedAttachment
    let hasText: Bool

    init(attachment: UnmanagedAttachment, hasText: Bool, user: UnmanagedUser?, message: UnmanagedMessage?) {
        self.attachment = attachment
        self.hasText = hasText
        super.init(user: user, avatar: message?.avatar, emoji: message?.emoji, date: message?.createdAt)
    }

    var differenceIdentifier: String {
        return attachment.identifier
    }

    func isContentEqual(to source: QuoteChatItem) -> Bool {
        return attachment.title == source.attachment.title &&
            attachment.text == source.attachment.text &&
            attachment.collapsed == source.attachment.collapsed
    }

    func toggle() {
        let filter = "identifier = '\(self.attachment.identifier)'"

        Realm.executeOnMainThread({ realm in
            if let attachment = realm.objects(Attachment.self).filter(filter).first {
                attachment.collapsed = !self.attachment.collapsed
                realm.add(attachment, update: true)
            }
        })
    }
}
