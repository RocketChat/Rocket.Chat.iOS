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

final class QuoteChatItem: BaseTextAttachmentChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return hasText ? QuoteCell.identifier : QuoteMessageCell.identifier
    }

    let identifier: String
    let purpose: String
    let title: String
    let text: String?
    let hasText: Bool

    init(identifier: String,
         purpose: String,
         title: String,
         text: String?,
         collapsed: Bool,
         hasText: Bool,
         user: UnmanagedUser?,
         message: UnmanagedMessage?) {

        self.identifier = identifier
        self.purpose = purpose
        self.title = title
        self.text = text
        self.hasText = hasText

        super.init(
            collapsed: collapsed,
            user: user,
            message: message
        )
    }

    var differenceIdentifier: String {
        return identifier
    }

    func isContentEqual(to source: QuoteChatItem) -> Bool {
        return title == source.title &&
            text == source.text &&
            collapsed == source.collapsed &&
            purpose.isEmpty == source.purpose.isEmpty
    }
}
