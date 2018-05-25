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
            case .error(let error):
                switch error {
                case .error:
                    self.loginVersionFallback(params: params, completion: completion)
                default:
                    completion(response)
                }
            }
        }
    }

    fileprivate func loginVersionFallback(params: LoginParams, completion: @escaping (APIResponse<LoginResource>) -> Void) {
        let object = [
            "msg": "method",
            "method": "login",
            "params": [params]
        ] as [String: Any]

        SocketManager.send(object) { (response) in
            let result = response.result

            guard !response.isError() else {
                completion(.resource(.init(raw: ["error": result["error"]])))
                return
            }

            let auth = Auth()
            auth.internalFirstChannelOpened = false
            auth.lastSubscriptionFetchWithLastMessage = nil
            auth.lastAccess = Date()
            auth.serverURL = response.socket?.currentURL.absoluteString ?? ""
            auth.token = result["result"]["token"].string
            auth.userId = result["result"]["id"].string

            if let date = result["result"]["tokenExpires"]["$date"].double {
                auth.tokenExpires = Date.dateFromInterval(date)
            }

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

            let resource = LoginResource(raw: [
                "status": "success",
                "data": [
                    "authToken": auth.token ?? "",
                    "userId": auth.userId ?? ""
                ]
            ])

            completion(.resource(resource))
        }
    }
}
