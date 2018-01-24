//
//  DeepLink.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/24/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

enum DeepLink {
    case auth(host: String)
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
            self = .auth(host: host)
        case "room":
            self = .room
        default:
            return nil
        }
    }
}
