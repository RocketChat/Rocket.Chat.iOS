//
//  LoaderChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 13/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct LoaderChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return LoaderCell.identifier
    }

    let identifier = String.random()

    var differenceIdentifier: String {
        return identifier
    }

    func isContentEqual(to source: LoaderChatItem) -> Bool {
        return identifier == source.identifier
    }
}
