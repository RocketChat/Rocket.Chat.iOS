//
//  FileMessageChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 28/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

final class FileMessageChatItem: BaseMessageChatItem, ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return hasText ? FileCell.identifier : FileMessageCell.identifier
    }

    var attachment: UnmanagedAttachment
    let hasText: Bool

    init(attachment: UnmanagedAttachment, hasText: Bool, user: UnmanagedUser?, message: UnmanagedMessage?) {
        self.attachment = attachment
        self.hasText = hasText

        super.init(
            user: user,
            message: message
        )
    }

    var differenceIdentifier: String {
        return attachment.fullFileURL?.absoluteString ?? attachment.titleLink
    }

    func isContentEqual(to source: FileMessageChatItem) -> Bool {
        return attachment.fullFileURL == source.attachment.fullFileURL
    }
}
