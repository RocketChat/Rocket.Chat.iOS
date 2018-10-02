//
//  ImageMessageChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 01/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct ImageMessageChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return ImageMessageCell.identifier
    }

    var identifier: String
    var title: String?
    var descriptionText: String?
    var imageURL: URL?

    var differenceIdentifier: String {
        return identifier
    }

    func isContentEqual(to source: ImageMessageChatItem) -> Bool {
        return
            identifier == source.identifier &&
            imageURL == source.imageURL &&
            title == source.title &&
            descriptionText == source.descriptionText
    }
}
