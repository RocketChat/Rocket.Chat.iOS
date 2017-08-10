//
//  AuthManager.swift
//  Rocket.Chat
//
//  Created by Rafael K. Streit on 7/8/16.
//  Copyright © 2016 Rocket.Chat. All rights reserved.
//

import Foundation
import RealmSwift


struct AuthManagerPersistKeys {
    static let token = "kAuthToken"
    static let serverURL = "kAuthServerURL"
    static let userId = "kUserId"
}


/// A manager that manages all authentication related actions
public class AuthManager: SocketManagerInjected, PushManagerInjected, ServerManagerInjected {
    /// Last auth object (sorted by lastAccess), if exists; nil otherwise.
    ///
    /// - Returns: an instance of `Auth`
    public func isAuthenticated() -> Auth? {
        guard let auths = try? Realm().objects(Auth.self).sorted(byKeyPath: "lastAccess", ascending: false) else { return nil}
        return auths.first
    }

    /**
        - returns:
    */
    /// Get current user, if exists; nil otherwise.
    ///
    /// - Returns: an instance of `User`
    public func currentUser() -> User? {
        guard let auth = isAuthenticated() else { return nil }
        guard let user = try? Realm().object(ofType: User.self, forPrimaryKey: auth.userId) else { return nil }
        return user
    }

    /**
        This method is going to persist the authentication informations
        that was latest used in NSUserDefaults to keep it safe if something
        goes wrong on database migration.
     */
    func persistAuthInformation(_ auth: Auth) {
        let defaults = UserDefaults.standard
        defaults.set(auth.token, forKey: AuthManagerPersistKeys.token)
        defaults.set(auth.serverURL, forKey: AuthManagerPersistKeys.serverURL)
        defaults.set(auth.userId, forKey: AuthManagerPersistKeys.userId)
    }

    func recoverAuthIfNeeded() {
        if isAuthenticated() != nil {
            return
        }

        guard
            let token = UserDefaults.standard.string(forKey: AuthManagerPersistKeys.token),
            let serverURL = UserDefaults.standard.string(forKey: AuthManagerPersistKeys.serverURL),
            let userId = UserDefaults.standard.string(forKey: AuthManagerPersistKeys.userId) else {
                return
        }

        Realm.executeOnMainThread({ (realm) in
            // Clear database
            realm.deleteAll()

            let auth = Auth()
            auth.lastSubscriptionFetch = nil
            auth.lastAccess = Date()
            auth.serverURL = serverURL
            auth.token = token
            auth.userId = userId

            self.pushManager.updatePushToken()

            realm.add(auth)
        })
    }

    // MARK: Socket Management

    /// This method resumes a previous authentication with token stored in the Realm object.
    ///
    /// - Parameters:
    ///   - auth: The Auth object that user wants to resume
    ///   - completion: The completion callback that will be called in case of success or error
    public func resume(_ auth: Auth, completion: @escaping MessageCompletion) {
        guard let url = URL(string: auth.serverURL) else { return }

        socketManager.connect(url) { (socket, connected) in
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

            self.socketManager.send(object) { (response) in
                guard !response.isError() else {
                    completion(response)
                    return
                }

                self.pushManager.updatePushToken()
                completion(response)
            }
        }
    }

    /// Sign up a new user with given username, email, and password, completion will be called after action been completed.
    ///
    /// - Parameters:
    ///   - name: username
    ///   - email: user's email
    ///   - password: a strong password
    ///   - completion: will be called after action completion
    public func signup(with name: String, _ email: String, _ password: String, completion: @escaping MessageCompletion) {
        let object = [
            "msg": "method",
            "method": "registerUser",
            "params": [[
                "email": email,
                "pass": password,
                "name": name
            ]]
        ] as [String : Any]

        socketManager.send(object) { (response) in
            guard !response.isError() else {
                completion(response)
                return
            }

            self.auth(email, password: password, completion: completion)
        }
    }

    /// A generic method that authenticated a user, should not be used directly unless you exactly know what you're doing
    ///
    /// - Parameters:
    ///   - params: a dictionary of params that will be sent to server
    ///   - completion: will be called after action completion
    public func auth(params: [String: Any], completion: @escaping MessageCompletion) {
        let object = [
            "msg": "method",
            "method": "login",
            "params": [params]
        ] as [String : Any]

        socketManager.send(object) { (response) in
            guard !response.isError() else {
                completion(response)
                return
            }

            Realm.execute({ (realm) in
                // Delete all the Auth objects, since we don't
                // support multiple-server authentication yet
                realm.delete(realm.objects(Auth.self))

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

                self.pushManager.updatePushToken()

                realm.add(auth)
            }, completion: {
                self.serverManager.timestampSync()
                completion(response)
            })
        }
    }

    /// Authenticate a user with given email and password.
    ///
    /// - Parameters:
    ///   - username: username of the user
    ///   - password: password of the user
    ///   - code: totp authentication code if exists, nil otherwise
    ///   - completion: will be called after action completion
    public func auth(_ username: String, password: String, code: String? = nil, completion: @escaping MessageCompletion) {
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

    /// Get the username suggestion for the logged in user.
    ///
    /// - Parameter completion: will be called after action completion
    public func usernameSuggestion(completion: @escaping MessageCompletion) {
        let object = [
            "msg": "method",
            "method": "getUsernameSuggestion"
        ] as [String : Any]

        socketManager.send(object, completion: completion)
    }

    /// Set username of the logged in user.
    ///
    /// - Parameters:
    ///   - username: new username
    ///   - completion: will be called after action completion
    public func setUsername(_ username: String, completion: @escaping MessageCompletion) {
        let object = [
            "msg": "method",
            "method": "setUsername",
            "params": [username]
        ] as [String : Any]

        socketManager.send(object, completion: completion)
    }

    /// Logouts user from the app, clear database and disconnects from the socket.
    ///
    /// - Parameter completion: will be called after action completion
    public func logout(completion: @escaping VoidCompletion) {
        socketManager.disconnect { (_, _) in
            self.socketManager.clear()

            let defaults = UserDefaults.standard
            defaults.removeObject(forKey: AuthManagerPersistKeys.token)
            defaults.removeObject(forKey: AuthManagerPersistKeys.serverURL)
            defaults.removeObject(forKey: AuthManagerPersistKeys.userId)

            Realm.executeOnMainThread({ (realm) in
                realm.deleteAll()
            })

            completion()
        }
    }

    /// Update server settings and public informations
    ///
    /// - Parameters:
    ///   - auth: the auth server to be updated
    ///   - completion: will be called after action completion
    public func updatePublicSettings(_ auth: Auth?, completion: @escaping MessageCompletionObject<AuthSettings?>) {
        let object = [
            "msg": "method",
            "method": "public-settings/get"
        ] as [String : Any]

        socketManager.send(object) { (response) in
            guard !response.isError() else {
                completion(nil)
                return
            }

            Realm.executeOnMainThread({ realm in
                let settings = self.isAuthenticated()?.settings ?? AuthSettings()
                settings.map(response.result["result"], realm: realm)
                realm.add(settings, update: true)

                if let auth = self.isAuthenticated() {
                    auth.settings = settings
                    realm.add(auth, update: true)
                }

                let unmanagedSettings = AuthSettings(value: settings)
                completion(unmanagedSettings)
            })
        }
    }
}
