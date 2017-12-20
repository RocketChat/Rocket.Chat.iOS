//
//  AuthClient.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 12/19/17.
//  Copyright © 2017 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

struct AuthClient: APIClient {
    let api: AnyAPIFetcher
    init(api: AnyAPIFetcher) {
        self.api = api
    }

    func register(name: String, email: String, username: String,
                  password: String, customFields: [String: String] = [:],
                  succeeded: RegisterSucceeded? = nil, errored: APIErrored? = nil) {
        let request = RegisterRequest(
            name: name, email: email, username: username,
            password: password, customFields: customFields
        )

        api.fetch(request, succeeded: { result in
            if let error = result.error {
                Alert.registerError.withMessage(error).present()
                errored?(APIError.custom(message: error))
                return
            }
            succeeded?(result)
        }, errored: { error in
            Alert.registerError.present()
            errored?(error)
        })
    }

    func login(username: String, password: String,
               succeeded: LoginSucceeded? = nil, errored: APIErrored? = nil) {
        let request = LoginRequest(username, password)

        api.fetch(request, succeeded: { result in
            if let error = result.error {
                Alert.loginError.withMessage(error).present()
                errored?(APIError.custom(message: error))
                return
            }

            let auth = Auth()
            auth.lastSubscriptionFetch = nil
            auth.lastAccess = Date()
            auth.serverURL = self.api.host.absoluteString
            auth.token = result.authToken
            auth.userId = result.userId

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
            succeeded?(result)
        }, errored: { error in
            Alert.loginError.present()
            errored?(error)
        })
    }
}
