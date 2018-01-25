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
    case room

    init?(url: URL) {
        guard
            url.scheme == "rocketchat",
            let actionString = url.host,
            let host = url.queryParameters?["host"]
        else {
            return nil
        }

        switch actionString {
        case "auth":
            var credentials: DeepLinkCredentials? = nil

            if let token = url.queryParameters?["token"],
                let userId = url.queryParameters?["userId"] {
                credentials = (token: token, userId: userId)
            }

            self = .auth(host: host, credentials: credentials)
        case "room":
            self = .room
        default:
            return nil
        }
    }
}
