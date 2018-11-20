//
//  MessageURLChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 04/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct MessageURLChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return MessageURLCell.identifier
    }

    var url: String
    var imageURL: String?
    var title: String
    var subtitle: String

    var differenceIdentifier: String {
        return url
    }

    func isContentEqual(to source: MessageURLChatItem) -> Bool {
        return title == source.title &&
            subtitle == source.subtitle &&
            imageURL == source.imageURL
    }
}
