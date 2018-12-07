//
//  UnreadMarkerChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 25/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct UnreadMarkerChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return UnreadMarkerCell.identifier
    }

    var identifier: String

    var differenceIdentifier: String {
        return identifier
    }

    func isContentEqual(to source: UnreadMarkerChatItem) -> Bool {
        return identifier == source.identifier
    }
}
