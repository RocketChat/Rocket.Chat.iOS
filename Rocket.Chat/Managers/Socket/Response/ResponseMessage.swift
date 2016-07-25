//
//  ResponseMessage.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/25/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//


enum ResponseMessage {
    case Connected, Failed, Error, Ping, Pong, Changed, Updated, Removed
    
    case Unknown
    
    init?(_ value: String) {
        switch value {
        case "connected":
            self = .Connected
            break
            
        case "failed":
            self = .Failed
            break
            
        case "error":
            self = .Error
            break
            
        case "ping":
            self = .Ping
            break
            
        case "pong":
            self = .Pong
            break
            
        case "changed":
            self = .Changed
            break
            
        case "updated":
            self = .Updated
            break
            
        case "removed":
            self = .Removed
            break
            
        default:
            self = .Unknown
        }
    }
}