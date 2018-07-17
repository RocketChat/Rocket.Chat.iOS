//
//  VersionMiddleware.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

struct VersionMiddleware: APIRequestMiddleware {
    weak var api: API?

    init(api: API) {
        self.api = api
    }

    func handle<R: APIRequest>(_ request: inout R) -> APIError? {
        guard let api = api else {
            return nil
        }

        if api.version < request.requiredVersion {
            return APIError.version(available: api.version, required: request.requiredVersion)
        }

        return nil
    }
}
