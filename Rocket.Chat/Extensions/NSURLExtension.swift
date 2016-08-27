//
//  NSURLExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/27/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

extension NSURL {
    
    func socketURL() -> NSURL? {
        let pathComponents = self.pathComponents ?? []
        let components = NSURLComponents()
        components.scheme = "wss"
        components.host = self.host
        components.path = self.path
        
        var newURL = components.URL
        if !pathComponents.contains("websocket") {
            newURL = newURL?.URLByAppendingPathComponent("websocket")
        }
        
        return newURL
    }
    
}
