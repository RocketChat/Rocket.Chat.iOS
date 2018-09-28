//
//  VideoMessageChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct VideoMessageChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return VideoMessageCell.identifier
    }

    var identifier: String
    var descriptionText: String?
    var videoURL: URL?
    var videoThumbPath: URL?

    var differenceIdentifier: String {
        return videoURL?.absoluteString ?? ""
    }

    func isContentEqual(to source: VideoMessageChatItem) -> Bool {
        return identifier == source.identifier && videoURL == source.videoURL
    }
}
