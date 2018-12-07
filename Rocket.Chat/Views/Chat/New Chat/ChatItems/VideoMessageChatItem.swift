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

final class VideoMessageChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return hasText ? VideoCell.identifier : VideoMessageCell.identifier
    }

    let attachment: UnmanagedAttachment
    let identifier: String
    let descriptionText: String?
    let videoURL: URL?
    let videoThumbPath: URL?
    let hasText: Bool

    init(
        attachment: UnmanagedAttachment,
        identifier: String,
        descriptionText: String?,
        videoURL: URL?,
        videoThumbPath: URL?,
        hasText: Bool,
        user: UnmanagedUser?,
        message: UnmanagedMessage?
        ) {

        self.attachment = attachment
        self.identifier = identifier
        self.descriptionText = descriptionText
        self.videoURL = videoURL
        self.videoThumbPath = videoThumbPath
        self.hasText = hasText

        super.init(
            user: user,
            message: message
        )
    }

    var differenceIdentifier: String {
        return videoURL?.absoluteString ?? ""
    }

    func isContentEqual(to source: VideoMessageChatItem) -> Bool {
        return identifier == source.identifier && videoURL == source.videoURL
    }
}
