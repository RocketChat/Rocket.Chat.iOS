//
//  MessageDiscussionChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Kellermann Streit on 03/04/19.
//  Copyright © 2019 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

final class MessageDiscussionChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return MessageDiscussionCell.identifier
    }

    override init(user: UnmanagedUser?, message: UnmanagedMessage?) {
        super.init(user: nil, message: message)
    }

    var differenceIdentifier: String {
        return message?.identifier ?? ""
    }

    func isContentEqual(to source: MessageDiscussionChatItem) -> Bool {
        guard let message = message, let sourceMessage = source.message else {
            return false
        }

        return message == sourceMessage
    }
}
