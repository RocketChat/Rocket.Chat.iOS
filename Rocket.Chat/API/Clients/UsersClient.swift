//
//  UsersClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 6/29/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct UsersClient: APIClient {
    let api: AnyAPIFetcher

    func fetchUser(_ user: User, realm: Realm? = Realm.current, completion: @escaping (APIResponse<UserInfoResource>) -> Void) {
        let request = UserInfoRequest(userId: user.identifier ?? "")

        api.fetch(request) { response in
            if case let .resource(resource) = response, let user = resource.user {
                Realm.executeOnMainThread(realm: realm) { realm in
                    realm.add(user, update: true)
                }
            }

            completion(response)
        }
    }
}
