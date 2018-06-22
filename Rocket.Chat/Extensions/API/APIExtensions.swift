//
//  APIExtensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension API {
    static var current: API?

    static func current(auth: Auth? = AuthManager.isAuthenticated()) -> API? {
        guard
            let auth = auth,
            let host = auth.apiHost?.httpServerURL() ?? auth.apiHost
        else {
            return nil
        }

        var api: API

        if let current = current {
            api = current
        } else {
            api = API(host: host, version: Version(auth.serverVersion) ?? .zero)
        }

        api.host = host
        api.version = Version(auth.serverVersion) ?? .zero
        api.userId = auth.userId
        api.authToken = auth.token
        api.language = AppManager.language

        current = api

        return api
    }

    static func server(index: Int) -> API? {
        let realm = DatabaseManager.databaseInstace(index: index)
        let auth = AuthManager.isAuthenticated(realm: realm)
        return current(auth: auth)
    }
}
