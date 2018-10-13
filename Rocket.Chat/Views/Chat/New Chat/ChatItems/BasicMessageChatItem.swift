//
//  BasicMessageChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 23/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

final class BasicMessageChatItem: MessageHeaderChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return BasicMessageCell.identifier
    }

    var message: UnmanagedMessage

    init(user: UnmanagedUser, message: UnmanagedMessage) {
        self.message = message
        super.init(user: user, avatar: message.avatar ?? "", emoji: message.emoji ?? "", date: message.createdAt)
    }

    var differenceIdentifier: String {
        return user.differenceIdentifier + message.identifier
    }

    func isContentEqual(to source: BasicMessageChatItem) -> Bool {
        return
            user.name == source.user.name &&
            user.username == source.user.username &&
            message.temporary == source.message.temporary &&
            message.failed == source.message.failed &&
            message.text == source.message.text &&
            message.updatedAt?.timeIntervalSince1970 == source.message.updatedAt?.timeIntervalSince1970
    }
}
