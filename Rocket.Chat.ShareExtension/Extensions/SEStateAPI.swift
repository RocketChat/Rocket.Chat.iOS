//
//  SEStateAPI.swift
//  Rocket.Chat.ShareExtension
//
//  Created by Matheus Cardoso on 7/23/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Foundation

extension SEState {
    var api: API? {
        guard
            let server = selectedServer,
            let api = API(host: server.host, version: Version(0, 60, 0))
        else {
            return nil
        }

        api.userId = server.userId
        api.authToken = server.token

        return api
    }
}
