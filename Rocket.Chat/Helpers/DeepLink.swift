//
//  DeepLink.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/24/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

typealias DeepLinkCredentials = (token: String, userId: String)

enum DeepLink {
    case auth(host: String, credentials: DeepLinkCredentials?)
    case room(host: String, roomId: String)

    case mention(name: String)
    case channel(name: String)

    init?(url: URL) {
        guard
            url.scheme == "rocketchat",
            let actionString = url.host
        else {
            return nil
        }

        switch actionString {

        case "auth":
            guard let host = url.queryParameters?["host"] else { return nil }

            var credentials: DeepLinkCredentials? = nil

            if let token = url.queryParameters?["token"],
                let userId = url.queryParameters?["userId"] {
                credentials = (token: token, userId: userId)
            }

            self = .auth(host: host, credentials: credentials)

        case "room":
            guard
                let host = url.queryParameters?["host"],
                let roomId = url.queryParameters?["rid"]
            else {
                return nil
            }

            self = .room(host: host, roomId: roomId)

        case "mention":
            guard let name = url.queryParameters?["name"] else {
                return nil
            }

            self = .mention(name: name)

        case "channel":
            guard let name = url.queryParameters?["name"] else {
                return nil
            }

            self = .channel(name: name)

        default:
            return nil

        }
    }
}
