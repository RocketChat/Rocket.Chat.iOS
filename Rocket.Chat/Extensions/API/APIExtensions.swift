//
//  APIExtensions.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/27/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

extension API {
    static func current(auth: Auth? = AuthManager.isAuthenticated()) -> API? {
        guard
            let auth = auth,
            let host = auth.apiHost
        else {
            return nil
        }

        let api = API(host: host)
        api.userId = auth.userId
        api.authToken = auth.token

        return api
    }
}
