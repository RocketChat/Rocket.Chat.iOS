//
//  MessageHeaderChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 12/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

class BaseMessageChatItem {
    let user: UnmanagedUser?
    let avatar: String?
    let emoji: String?
    let date: Date?
    let isUnread: Bool
    var dateFormatted: String {
        guard let date = date else {
            return ""
        }

        return RCDateFormatter.time(date)
    }

    init(user: UnmanagedUser?, avatar: String?, emoji: String?, date: Date?, isUnread: Bool = false) {
        self.user = user
        self.avatar = avatar
        self.emoji = emoji
        self.date = date
        self.isUnread = isUnread
    }
}
