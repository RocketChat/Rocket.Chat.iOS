//
//  UserClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 4/17/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct UserClient: APIClient {
    let api: AnyAPIFetcher
    init(api: AnyAPIFetcher) {
        self.api = api
    }

    func fetchCurrentUser(realm: Realm? = Realm.current) {
        let request = MeRequest()
        api.fetch(request, completion: { response in
            switch response {
            case .resource(let resource):
                guard let user = resource.user else { return }
                realm?.execute({ realm in
                    realm.add(user, update: true)
                })
            case .error:
                break
            }
        })
    }
}
