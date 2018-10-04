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

    var attachment: Attachment

    var differenceIdentifier: String {
        return attachment.identifier ?? ""
    }

    func isContentEqual(to source: QuoteChatItem) -> Bool {
        return attachment.title == source.attachment.title &&
            attachment.text == source.attachment.text &&
            attachment.collapsed == source.attachment.collapsed
    }

    func toggle() {
        Realm.executeOnMainThread({ _ in
            self.attachment.collapsed = !self.attachment.collapsed
        })
    }
}
