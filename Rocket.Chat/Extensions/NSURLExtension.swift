//
//  NSURLExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/27/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

extension URL {
    
    func socketURL() -> URL? {
        let pathComponents = self.pathComponents 
        var components = URLComponents()
        components.scheme = "wss"
        components.host = self.host
        components.path = self.path
        
        var newURL = components.url
        if !pathComponents.contains("websocket") {
            newURL = newURL?.appendingPathComponent("websocket")
        }
        
        return newURL
    }
    
}
