//
//  TextAttachmentChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 30/09/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation
import DifferenceKit
import RocketChatViewController

struct TextAttachmentChatItem: ChatItem, Differentiable {
    var relatedReuseIdentifier: String {
        return TextAttachmentCell.identifier
    }

    var attachment: Attachment

    var differenceIdentifier: String {
        return attachment.title
    }

    func isContentEqual(to source: TextAttachmentChatItem) -> Bool {
        return attachment.collapsed == source.attachment.collapsed && attachment.fields == source.attachment.fields
    }
}
