//
//  APIExtensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension API {
    static func current() -> API? {
        guard
            let auth = AuthManager.isAuthenticated(),
            let host = auth.apiHost else {
            return nil
        }

        let api = API(host: host, version: Version(auth.serverVersion) ?? .zero)
        api.userId = auth.userId
        api.authToken = auth.token

        return api
    }
}
