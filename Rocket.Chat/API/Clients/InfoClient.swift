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

    func fetchInfo(realm: Realm? = Realm.current) {
        api.fetch(InfoRequest()) { response in
            switch response {
            case .resource(let resource):
                guard let version = resource.version else { return }
                realm?.execute({ realm in
                    AuthManager.isAuthenticated(realm: realm)?.serverVersion = "\(version)"
                })
            case .error:
                return
            }
        }
    }
}
