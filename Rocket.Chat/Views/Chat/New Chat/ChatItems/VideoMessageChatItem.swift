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

final class VideoMessageChatItem: MessageHeaderChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return hasText ? VideoCell.identifier : VideoMessageCell.identifier
    }

    let identifier: String
    let descriptionText: String?
    let videoURL: URL?
    let videoThumbPath: URL?
    let hasText: Bool

    init(identifier: String, descriptionText: String?, videoURL: URL?, videoThumbPath: URL?, hasText: Bool, user: UnmanagedUser?, message: UnmanagedMessage?) {
        self.identifier = identifier
        self.descriptionText = descriptionText
        self.videoURL = videoURL
        self.videoThumbPath = videoThumbPath
        self.hasText = hasText
        super.init(user: user, avatar: message?.avatar, emoji: message?.emoji, date: message?.createdAt)
    }

    var differenceIdentifier: String {
        return videoURL?.absoluteString ?? ""
    }

    func isContentEqual(to source: VideoMessageChatItem) -> Bool {
        return identifier == source.identifier && videoURL == source.videoURL
    }
}
