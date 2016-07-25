//
//  ResponseEvent.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//


enum ResponseEvent {
    case Notify
    case Unknown
    
    init?(_ value: String) {
        switch value {
        case "stream-notify-user":
            self = .Notify
            break
        default:
            self = .Unknown
        }
    }
    
}