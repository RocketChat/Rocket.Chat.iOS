//
//  URLExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/27/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

extension URL {

    func validateURL() -> URL? {
        var newURL = self
        newURL = newURL.appendingPathComponent("api/info")
        return newURL
    }

    func socketURL() -> URL? {
        let pathComponents = self.pathComponents
        var components = URLComponents()
        components.scheme = "wss"
        components.host = self.host != nil ? self.host : self.path
        components.path = self.host != nil ? self.path : ""

        var newURL = components.url
        if !pathComponents.contains("websocket") {
            newURL = newURL?.appendingPathComponent("websocket")
        }

        return newURL
    }

}
