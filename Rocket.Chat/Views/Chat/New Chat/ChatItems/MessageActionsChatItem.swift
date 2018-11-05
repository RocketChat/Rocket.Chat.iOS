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

struct MessageActionsChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return MessageActionsCell.identifier
    }

    let message: UnmanagedMessage

    var differenceIdentifier: String {
        return message.identifier
    }

    func isContentEqual(to source: MessageActionsChatItem) -> Bool {
        return message == source.message
    }
}
