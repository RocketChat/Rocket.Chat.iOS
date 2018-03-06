//
//  AuthManager+Socket.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift
import GoogleSignIn

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

        // Turn all users offline
        Realm.execute({ (realm) in
            let users = realm.objects(User.self)
            users.setValue("offline", forKey: "privateStatus")
        })

        SocketManager.connect(url) { (socket, _) in
            guard SocketManager.isConnected() else {
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
                    SocketManager.disconnect({ (_, _) in
                        completion(response)
                    })

                    return
                }

                PushManager.updatePushToken()
                SocketManager.sharedInstance.isUserAuthenticated = true
                completion(response)
            }
        }
    }

    static func auth(token: String, completion: @escaping MessageCompletion) {
        auth(params: ["resume": token], completion: completion)
    }

    /**
     Method that creates an User account.
     */
    static func signup(with name: String, _ email: String, _ password: String, customFields: [String: String] = [String: String](), completion: @escaping MessageCompletion) {
        let param = [
            "email": email,
            "pass": password,
            "name": name
            ].union(dictionary: customFields)

        let object = [
            "msg": "method",
            "method": "registerUser",
            "params": [param]
            ] as [String: Any]

        SocketManager.send(object, completion: completion)
    }

    /**
     Generic method that authenticates the user.
     */
    static func auth(params: [String: Any], completion: @escaping MessageCompletion) {
        let object = [
            "msg": "method",
            "method": "login",
            "params": [params]
            ] as [String: Any]

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

            persistAuthInformation(auth)
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
     This method authenticates the user with a credential token
     and a credential secret (retrieved via an OAuth method)

     - parameter token: The credential token
     - parameter secret: The credential secret
     - parameter completion: The completion block that'll be called in case
     of success or error.
     */
    static func auth(credentials: OAuthCredentials, completion: @escaping MessageCompletion) {
        let params = [
            "oauth": [
                "credentialToken": credentials.token,
                "credentialSecret": credentials.secret ?? ""
                ] as [String: Any]
        ]

        AuthManager.auth(params: params, completion: completion)
    }

    /**
     This method authenticates the user with a CAS credential token

     - parameter token: The credential token
     - parameter completion: The completion block that'll be called in case
     of success or error.
     */
    static func auth(casCredentialToken: String, completion: @escaping MessageCompletion) {
        let params = [
            "cas": [
                "credentialToken": casCredentialToken
                ] as [String: Any]
        ]

        AuthManager.auth(params: params, completion: completion)
    }

    static func auth(samlCredentialToken: String, completion: @escaping MessageCompletion) {
        let params = [
            "saml": true,
            "credentialToken": samlCredentialToken
            ] as [String: Any]

        AuthManager.auth(params: params, completion: completion)
    }

    /**
     Sends forgot password request for e-mail.
     */
    static func sendForgotPassword(email: String, completion: @escaping MessageCompletion = { _ in }) {
        let object = [
            "msg": "method",
            "method": "sendForgotPasswordEmail",
            "params": [email]
            ] as [String: Any]

        SocketManager.send(object, completion: completion)
    }

    /**
     Returns the username suggestion for the logged in user.
     */
    static func usernameSuggestion(completion: @escaping MessageCompletion) {
        let object = [
            "msg": "method",
            "method": "getUsernameSuggestion"
            ] as [String: Any]

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
            ] as [String: Any]

        SocketManager.send(object, completion: completion)
    }

    /**
     Logouts user from the app, clear database
     and disconnects from the socket.
     */
    static func logout(completion: @escaping VoidCompletion) {
        SocketManager.disconnect { (_, _) in
            GIDSignIn.sharedInstance().signOut()

            DraftMessageManager.clearServerDraftMessages()

            Realm.executeOnMainThread({ (realm) in
                realm.deleteAll()
            })

            AuthSettingsManager.shared.clearCachedSettings()
            DatabaseManager.removeSelectedDatabase()
            completion()
        }
    }

}
