//
//  AuthManagerSocket.swift
//  Rocket.Chat
//
//  Created by Matheus Cardoso on 3/1/18.
//  Copyright © 2018 Rocket.Chat. All rights reserved.
//

import RealmSwift

extension AuthManager {

    /**
     This method resumes a previous authentication with token
     stored in the Realm object.

     - parameter auth The Auth object that user wants to resume.
     - parameter completion The completion callback that will be
     called in case of success or error.
     */
    static func resume(_ auth: Auth, completion: @escaping MessageCompletion) {
        guard
            let url = URL(string: auth.serverURL),
            let socketURL = url.socketURL()
        else {
            return
        }

        // Turn all users offline
        Realm.execute({ (realm) in
            let users = realm.objects(User.self)
            users.setValue("offline", forKey: "privateStatus")
        })

        SocketManager.connect(socketURL) { (socket, _) in
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

    static func auth(token: String, completion: @escaping (LoginResponse) -> Void) {
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
    static func auth(params: [String: Any], completion: @escaping (LoginResponse) -> Void) {
        guard let url = SocketManager.sharedInstance.serverURL?.httpServerURL() else {
            return completion(.error(.malformedRequest))
        }

        let client = API(host: url).client(AuthClient.self)
        client.login(params: params, completion: completion)
    }

    /**
     This method authenticates the user with email and password.

     - parameter username: Username
     - parameter password: Password
     - parameter completion: The completion block that'll be called in case
     of success or error.
     */
    static func auth(_ username: String, password: String, code: String? = nil, completion: @escaping (LoginResponse) -> Void) {
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
    static func auth(credentials: OAuthCredentials, completion: @escaping (LoginResponse) -> Void) {
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
    static func auth(casCredentialToken: String, completion: @escaping (LoginResponse) -> Void) {
        let params = [
            "cas": [
                "credentialToken": casCredentialToken
            ] as [String: Any]
        ]

        AuthManager.auth(params: params, completion: completion)
    }

    static func auth(samlCredentialToken: String, completion: @escaping (LoginResponse) -> Void) {
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
    static func setUsername(_ username: String, completion: @escaping (Bool, String?) -> Void) {
        let object = [
            "msg": "method",
            "method": "setUsername",
            "params": [username]
        ] as [String: Any]

        let req = UpdateUserRequest(username: username)
        API.current()?.fetch(req) { response in
            switch response {
            case .resource(let resource):
                if let errorMessage = resource.errorMessage {
                    return completion(false, errorMessage)
                }
                return completion(true, nil)
            case .error(let error):
                switch error {
                case .version:
                    SocketManager.send(object) { response in
                        if let message = response.result["error"]["message"].string {
                            completion(false, message)
                        }
                    }
                default:
                    completion(false, error.description)
                }
            }
        }
    }

    /**
     Logouts user from the app, clear database
     and disconnects from the socket.
     */
    static func logout(completion: @escaping VoidCompletion) {
        SocketManager.disconnect { (_, _) in
            BugTrackingCoordinator.anonymizeCrashReports()

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
