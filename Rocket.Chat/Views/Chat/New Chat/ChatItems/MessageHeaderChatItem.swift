//
//  MessageHeaderChatItem.swift
//  Rocket.Chat
//
//  Created by Filipe Alvarenga on 12/10/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

class MessageHeaderChatItem {
    var user: UnmanagedUser?
    var avatar: String?
    var emoji: String?
    var date: Date?
    var dateFormatted: String {
        guard let date = date else {
            return ""
        }

        return RCDateFormatter.time(date)
    }

    init(user: UnmanagedUser?, avatar: String?, emoji: String?, date: Date?) {
        self.user = user
        self.avatar = avatar
        self.emoji = emoji
        self.date = date
    }
}
