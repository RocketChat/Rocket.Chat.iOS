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

struct FileMessageChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return FileMessageCell.identifier
    }

    var attachment: UnmanagedAttachment

    var differenceIdentifier: String {
        return attachment.fullFileURL?.absoluteString ?? attachment.titleLink
    }

    func isContentEqual(to source: FileMessageChatItem) -> Bool {
        return attachment.fullFileURL == source.attachment.fullFileURL
    }
}
