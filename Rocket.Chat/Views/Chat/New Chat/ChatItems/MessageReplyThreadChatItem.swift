//
//  MessageReplyThreadChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 17/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

final class MessageReplyThreadChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var isSequential: Bool = false

    var relatedReuseIdentifier: String {
        return ThreadReplyCollapsedCell.identifier
    }

    init(user: UnmanagedUser?, message: UnmanagedMessage?, sequential: Bool = false) {
        super.init(user: user, message: message)
        isSequential = sequential
    }

    internal var threadName: String? {
        guard
            !isSequential,
            let message = message
        else {
            return nil
        }

        return message.mainThreadMessage
    }

    var differenceIdentifier: String {
        return message?.identifier ?? ""
    }

    func isContentEqual(to source: MessageReplyThreadChatItem) -> Bool {
        guard let message = message, let sourceMessage = source.message else {
            return false
        }

        return message == sourceMessage
    }
}
