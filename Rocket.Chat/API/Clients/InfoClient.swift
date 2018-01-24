//
//  InfoClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 11/28/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct InfoClient: APIClient {
    let api: AnyAPIFetcher

    func fetchInfo(realm: Realm? = Realm.shared) {
        api.fetch(InfoRequest(), succeeded: { result in
            realm?.execute({ realm in
                AuthManager.isAuthenticated(realm: realm)?.serverVersion = result.version ?? ""
            })
        }, errored: nil)
    }
}
