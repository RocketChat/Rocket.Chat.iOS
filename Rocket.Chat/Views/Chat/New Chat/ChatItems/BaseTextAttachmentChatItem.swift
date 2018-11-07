//
//  BaseTextAttachmentChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 06/11/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

class BaseTextAttachmentChatItem: BaseMessageChatItem {
    let collapsed: Bool

    init(collapsed: Bool, user: UnmanagedUser?, avatar: String?, emoji: String?, date: Date?, isUnread: Bool = false) {
        self.collapsed = collapsed
        super.init(user: user, avatar: avatar, emoji: emoji, date: date, isUnread: isUnread)
    }
}
