//
//  AudioMessageChatItem.swift
//  Rocket.Chat
//
//  Created by Rafael Streit on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct AudioMessageChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return AudioMessageCell.identifier
    }

    var title: String?
    var description: String?
    var audioURL: URL?

    var differenceIdentifier: String {
        return audioURL?.absoluteString ?? ""
    }

    func isContentEqual(to source: AudioMessageChatItem) -> Bool {
        return
            title == source.title &&
            description == source.description &&
            audioURL == source.audioURL
    }
}
