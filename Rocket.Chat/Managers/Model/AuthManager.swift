//
//  AuthManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift

struct AuthManager {
    /**
        - returns: Last auth object (sorted by lastAccess), if exists.
    */
    static func isAuthenticated() -> Auth? {
        guard let auths = try? Realm().objects(Auth.self).sorted(byKeyPath: "lastAccess", ascending: false) else { return nil}
        return auths.first
    }

    /**
        - returns: Current user object, if exists.
    */
    static func currentUser() -> User? {
        guard let auth = isAuthenticated() else { return nil }
        guard let user = try? Realm().object(ofType: User.self, forPrimaryKey: auth.userId) else { return nil }
        return user
    }
}

// MARK: Socket Management

extension AuthManager {

    /**
        This method resumes a previous authentication with token
        stored in the Realm object.
 
        - parameter auth The Auth object that user wants to resume.
        - parameter completion The completion callback that will be
            called in case of success or error.
    */
    static func resume(_ auth: Auth, completion: @escaping MessageCompletion) {
        guard let url = URL(string: auth.serverURL) else { return }

        SocketManager.connect(url) { (socket, connected) in
            guard connected else {
                guard let response = SocketResponse(
                    ["error": "Can't connect to the socket"],
                    socket: socket
                ) else { return }

                return completion(response)
            }

            let object = [
                "msg": "method",
                "method": "login",
                "params": [[
                    "resume": auth.token ?? ""
                ]]
            ] as [String: Any]

            SocketManager.send(object) { (response) in
                guard !response.isError() else {
                    completion(response)
                    return
                }

                PushManager.updatePushToken()
                completion(response)
            }
        }
    }

    /**
        Generic method that authenticates the user.
    */
    static func auth(params: [String: Any], completion: @escaping MessageCompletion) {
        let object = [
            "msg": "method",
            "method": "login",
            "params": [params]
        ] as [String : Any]

        SocketManager.send(object) { (response) in
            guard !response.isError() else {
                completion(response)
                return
            }

            let result = response.result

            let auth = Auth()
            auth.lastSubscriptionFetch = nil
            auth.lastAccess = Date()
            auth.serverURL = response.socket?.currentURL.absoluteString ?? ""
            auth.token = result["result"]["token"].string
            auth.userId = result["result"]["id"].string

            if let date = result["result"]["tokenExpires"]["$date"].double {
                auth.tokenExpires = Date.dateFromInterval(date)
            }

            PushManager.updatePushToken()

            Realm.update(auth)
            completion(response)
        }
    }

    /**
        This method authenticates the user with email and password.
 
        - parameter username: Username
        - parameter password: Password
        - parameter completion: The completion block that'll be called in case
            of success or error.
    */
    static func auth(_ username: String, password: String, code: String? = nil, completion: @escaping MessageCompletion) {
        let usernameType = username.contains("@") ? "email" : "username"
        var params: [String: Any]?

        if let code = code {
            params = [
                "totp": [
                    "login": [
                        "user": [usernameType: username],
                        "password": [
                            "digest": password.sha256(),
                            "algorithm": "sha-256"
                        ]
                    ],
                    "code": code
                ]
            ]
        } else {
            params = [
                "user": [usernameType: username],
                "password": [
                    "digest": password.sha256(),
                    "algorithm": "sha-256"
                ]
            ]
        }

        if let params = params {
            self.auth(params: params, completion: completion)
        }
    }

    /**
        Returns the username suggestion for the logged in user.
    */
    static func usernameSuggestion(completion: @escaping MessageCompletion) {
        let object = [
            "msg": "method",
            "method": "getUsernameSuggestion"
        ] as [String : Any]

        SocketManager.send(object, completion: completion)
    }

    /**
     Set username of logged in user
     */
    static func setUsername(_ username: String, completion: @escaping MessageCompletion) {
        let object = [
            "msg": "method",
            "method": "setUsername",
            "params": [username]
        ] as [String : Any]

        SocketManager.send(object, completion: completion)
    }

    /**
        Logouts user from the app, clear database
        and disconnects from the socket.
     */
    static func logout(completion: @escaping VoidCompletion) {
        SocketManager.disconnect { (_, _) in
            SocketManager.clear()
            GIDSignIn.sharedInstance().signOut()

            Realm.execute({ (realm) in
                realm.deleteAll()
            })

            completion()
        }
    }

    static func updatePublicSettings(_ auth: Auth?, completion: @escaping MessageCompletionObject<AuthSettings?>) {
        let object = [
            "msg": "method",
            "method": "public-settings/get"
        ] as [String : Any]

        SocketManager.send(object) { (response) in
            guard !response.isError() else {
                completion(nil)
                return
            }

            Realm.execute({ realm in
                var settings: AuthSettings?

                if let auth = AuthManager.isAuthenticated() {
                    settings = auth.settings
                } else {
                    settings = AuthSettings()
                }

                if let settings = settings {
                    settings.map(response.result["result"], realm: realm)
                    realm.add(settings, update: true)

                    if let auth = AuthManager.isAuthenticated() {
                        auth.settings = settings
                        realm.add(auth, update: true)
                    }

                    let unmanagedSettings = AuthSettings(value: settings)
                    completion(unmanagedSettings)
                }
            })
        }
    }
}
