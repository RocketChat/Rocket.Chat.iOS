//
//  PushClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/8/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation

struct PushClient: APIClient {
    let api: AnyAPIFetcher
    init(api: AnyAPIFetcher) {
        self.api = api
    }

    func deletePushToken(token: String? = PushManager.getDeviceToken()) {
        guard let token = token else { return }

        api.fetch(PushTokenDeleteRequest(token: token)) { response in
            switch response {
            case .resource:
                break
            case .error(let error):
                if case .version = error {
                    Alert(key: "alert.push_token_error").present()
                }
            }
        }
    }
}
