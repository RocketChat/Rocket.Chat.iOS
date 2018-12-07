//
//  MessageActionsChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 22/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

final class MessageActionsChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return MessageActionsCell.identifier
    }

    override init(user: UnmanagedUser?, message: UnmanagedMessage?) {
        super.init(user: nil, message: message)
    }

    var differenceIdentifier: String {
        return message?.identifier ?? ""
    }

    func isContentEqual(to source: MessageActionsChatItem) -> Bool {
        guard let message = message, let sourceMessage = source.message else {
            return false
        }

        return message == sourceMessage
    }
}
