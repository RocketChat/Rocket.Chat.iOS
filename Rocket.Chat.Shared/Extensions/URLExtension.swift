//
//  URLExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/27/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

extension URL {

    func validateURL(secured: Bool = true) -> URL? {
        var components = URLComponents()
        if secured {
            components.scheme = "https"
        } else {
            components.scheme = "http"
        }
        components.host = self.host != nil ? self.host : self.path
        components.path = self.host != nil ? self.path : ""
        components.port = self.port != nil ? self.port : nil

        var newURL = components.url
        newURL = newURL?.appendingPathComponent("api/info")
        return newURL
    }

    func socketURL(secured: Bool = true) -> URL? {
        let pathComponents = self.pathComponents
        var components = URLComponents()
        if secured {
            components.scheme = "wss"
        } else {
            components.scheme = "ws"
        }
        components.host = self.host != nil ? self.host : self.path
        components.path = self.host != nil ? self.path : ""
        components.port = self.port != nil ? self.port : nil

        var newURL = components.url
        if !pathComponents.contains("websocket") {
            newURL = newURL?.appendingPathComponent("websocket")
        }

        return newURL
    }

}
