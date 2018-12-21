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
    let message: UnmanagedMessage?
    var dateFormatted: String {
        guard let date = message?.createdAt else {
            return ""
        }

        return RCDateFormatter.time(date)
    }

    init(user: UnmanagedUser?, message: UnmanagedMessage?) {
        self.user = user
        self.message = message
    }
}
