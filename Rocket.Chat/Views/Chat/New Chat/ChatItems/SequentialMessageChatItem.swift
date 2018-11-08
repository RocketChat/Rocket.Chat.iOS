//
//  SequentialMessageChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

final class SequentialMessageChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return SequentialMessageCell.identifier
    }

    var message: UnmanagedMessage

    init(user: UnmanagedUser, message: UnmanagedMessage) {
        self.message = message
        super.init(user: user, avatar: message.avatar, emoji: message.emoji, date: message.createdAt, isUnread: message.unread)
    }

    var differenceIdentifier: String {
        return (user?.differenceIdentifier ?? "") + message.identifier
    }

    func isContentEqual(to source: SequentialMessageChatItem) -> Bool {
        return
            user?.name == source.user?.name &&
            user?.username == source.user?.username &&
            message.temporary == source.message.temporary &&
            message.failed == source.message.failed &&
            message.text == source.message.text &&
            message.updatedAt?.timeIntervalSince1970 == source.message.updatedAt?.timeIntervalSince1970
    }
}
