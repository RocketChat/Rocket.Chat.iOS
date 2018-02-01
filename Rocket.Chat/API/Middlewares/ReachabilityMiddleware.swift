//
//  ReachabilityMiddleware.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 1/31/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import Reachability

struct ReachabilityMiddleware: APIRequestMiddleware {
    let api: API

    func handle<R: APIRequest>(_ request: inout R) -> APIError? {
        guard NetworkManager.isConnected else {
            return APIError.noConnection
        }

        return nil
    }
}
