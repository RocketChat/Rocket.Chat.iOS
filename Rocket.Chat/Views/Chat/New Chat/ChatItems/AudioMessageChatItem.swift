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

class AudioMessageChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return hasText ? AudioCell.identifier : AudioMessageCell.identifier
    }

    let identifier: String
    let audioURL: URL?
    let hasText: Bool

    init(identifier: String, audioURL: URL?, hasText: Bool, user: UnmanagedUser?, message: UnmanagedMessage?) {
        self.identifier = identifier
        self.audioURL = audioURL
        self.hasText = hasText

        super.init(
            user: user,
            message: message
        )
    }

    var localAudioURL: URL? {
        return DownloadManager.localFileURLFor(identifier)
    }

    var differenceIdentifier: String {
        return audioURL?.absoluteString ?? ""
    }

    func isContentEqual(to source: AudioMessageChatItem) -> Bool {
        return identifier == source.identifier && audioURL == source.audioURL
    }
}
