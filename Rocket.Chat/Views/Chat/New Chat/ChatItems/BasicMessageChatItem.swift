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

final class BasicMessageChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return BasicMessageCell.identifier
    }

    init(user: UnmanagedUser, message: UnmanagedMessage) {
        super.init(
            user: user,
            message: message
        )
    }

    var differenceIdentifier: String {
        return (user?.differenceIdentifier ?? "") + (message?.identifier ?? "")
    }

    func isContentEqual(to source: BasicMessageChatItem) -> Bool {
        guard
            let user = user,
            let sourceUser = source.user,
            let message = message,
            let sourceMessage = source.message
        else {
            return false
        }

        return
            user.name == sourceUser.name &&
            user.username == sourceUser.username &&
            message.temporary == sourceMessage.temporary &&
            message.failed == sourceMessage.failed &&
            message.text == sourceMessage.text &&
            message.updatedAt?.timeIntervalSince1970 == sourceMessage.updatedAt?.timeIntervalSince1970
    }
}
