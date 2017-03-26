//
//  ResponseMessage.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

enum ResponseMessage: String {
    case connected = "connected"
    case error = "error"
    case ping = "ping"
    case changed = "changed"
    case added = "added"
    case updated = "updated"
    case removed = "removed"
    case unknown
}
