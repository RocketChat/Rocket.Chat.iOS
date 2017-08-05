//
//  URLExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/27/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

extension URL {

    func timestampURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.host != nil ? self.host : self.path
        components.path = ""
        components.port = self.port != nil ? self.port : nil

        var newURL = components.url
        newURL = newURL?.appendingPathComponent("_timesync")
        return newURL
    }

    func validateURL() -> URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = self.host != nil ? self.host : self.path
        components.path = self.host != nil ? self.path : ""
        components.port = self.port != nil ? self.port : nil

        var newURL = components.url
        newURL = newURL?.appendingPathComponent("api/info")
        return newURL
    }

    func socketURL() -> URL? {
        let pathComponents = self.pathComponents
        var components = URLComponents()
        components.scheme = "wss"
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
