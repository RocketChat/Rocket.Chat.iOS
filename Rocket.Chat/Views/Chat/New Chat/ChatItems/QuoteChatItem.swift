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

struct QuoteChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return QuoteCell.identifier
    }

    var attachment: UnmanagedAttachment

    var differenceIdentifier: String {
        return attachment.identifier
    }

    func isContentEqual(to source: QuoteChatItem) -> Bool {
        return attachment.title == source.attachment.title &&
            attachment.text == source.attachment.text &&
            attachment.collapsed == source.attachment.collapsed
    }

    func toggle() {
        Realm.executeOnMainThread({ realm in
            if let attachment = realm.objects(Attachment.self).filter("identifier = '\(self.attachment.identifier)'").first {
                attachment.collapsed = !self.attachment.collapsed
                realm.add(attachment, update: true)
            }
        })
    }
}
