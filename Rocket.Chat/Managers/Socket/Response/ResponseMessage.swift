//
//  ResponseMessage.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//


enum ResponseMessage: String {
    case Connected = "connected"
    case Error = "error"
    case Ping = "ping"
    case Changed = "changed"
    case Added = "added"
    case Updated = "updated"
    case Removed = "removed"
    case Unknown
}