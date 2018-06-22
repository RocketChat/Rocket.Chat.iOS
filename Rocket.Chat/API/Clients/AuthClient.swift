//
//  AuthClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 5/5/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

struct AuthClient: APIClient {
    let api: AnyAPIFetcher

    func login(params: LoginParams, completion: @escaping (APIResponse<LoginResource>) -> Void) {
        api.fetch(LoginRequest(params: params)) { response in
            switch response {
            case .resource(let resource):
                guard resource.status == "success" else {
                    return completion(.resource(.init(raw: ["error": resource.error ?? ""])))
                }

                let auth = Auth()
                auth.internalFirstChannelOpened = false
                auth.lastSubscriptionFetchWithLastMessage = nil
                auth.lastAccess = Date()
                auth.serverURL = (self.api as? API)?.host.absoluteString ?? ""
                auth.token = resource.authToken
                auth.userId = resource.userId

                AuthManager.persistAuthInformation(auth)
                DatabaseManager.changeDatabaseInstance()

                Realm.executeOnMainThread({ (realm) in
                    // Delete all the Auth objects, since we don't
                    // support multiple-server per database
                    realm.delete(realm.objects(Auth.self))

                    PushManager.updatePushToken()
                    realm.add(auth)
                })

                SocketManager.sharedInstance.isUserAuthenticated = true
                ServerManager.timestampSync()
                completion(response)
            case .error:
                completion(response)
            }
        }
    }
}
