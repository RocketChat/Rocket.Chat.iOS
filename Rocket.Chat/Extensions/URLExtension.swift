//
//  URLExtension.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 8/27/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation

extension URL {
    public var queryParameters: [String: String]? {
        guard
            let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
            let queryItems = components.queryItems
        else {
            return nil
        }

        var parameters = [String: String]()
        for item in queryItems {
            parameters[item.name] = item.value
        }

        return parameters
    }

    init?(string: String, scheme: String) {
        guard let url = URL(string: string) else {
            return nil
        }

        var port = ""
        if let _port = url.port {
            port = ":\(_port)"
        }

        var query = ""
        if let _query = url.query, !_query.isEmpty {
            query = "?\(_query)"
        }

        if let host = url.host, !host.isEmpty {
            self.init(string: "\(scheme)://\(host)\(port)\(url.path)\(query)")
            return
        }

        if !url.path.isEmpty {
            self.init(string: "\(scheme)://\(url.path)\(port)\(query)")
            return
        }

        return nil
    }

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

    mutating func removingDuplicatedSlashes() -> URL {
        let urlString = self.absoluteString.replacingOccurrences(of: "//", with: "/")

        if let newURL = URL(string: urlString) {
            self = newURL
        }

        return self
    }

}
