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
        return try! Realm().objects(Auth.self).sorted(byProperty: "lastAccess", ascending: false).first
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
        let url = URL(string: auth.serverURL)!
        SocketManager.connect(url) { (socket, connected) in
            guard connected else {
                let response = SocketResponse(
                    ["error": "Can't connect to the socket"],
                    socket: socket
                )

                return completion(response!)
            }
            
            let object = [
                "msg": "method",
                "method": "login",
                "params": [[
                    "resume": auth.token!
                ]]
            ] as [String: Any]
            
            SocketManager.send(object) { (response) in
                guard !response.isError() else {
                    // TODO: Logging or default behaviour on fails
                    completion(response)
                    return
                }

                completion(response)
            }
        }
    }
    
    
    /**
        This method authenticates the user with email and password.
 
        - parameter username: Username
        - parameter password: Password
        - parameter completion: The completion block that'll be called in case
            of success or error.
    */
    static func auth(_ username: String, password: String, completion: @escaping MessageCompletion) {
        let usernameType = username.contains("@") ? "email" : "username"
        let object = [
            "msg": "method",
            "method": "login",
            "params": [[
                "user": [
                    usernameType: username
                ],
                "password": [
                    "digest": password.sha256(),
                    "algorithm":"sha-256"
                ]
            ]]
        ] as [String : Any]

        SocketManager.send(object) { (response) in
            guard !response.isError() else {
                // TODO: Logging or default behaviour on fails
                completion(response)
                return
            }

            let result = response.result

            let auth = Auth()
            auth.lastSubscriptionFetch = nil
            auth.lastAccess = Date()
            auth.serverURL = response.socket!.currentURL.absoluteString
            auth.token = result["result"]["token"].string
            auth.userId = result["result"]["id"].string

            if let date = result["result"]["tokenExpires"]["$date"].double {
                auth.tokenExpires = Date.dateFromInterval(date)
            }
            
            Realm.update(auth)
            completion(response)
        }
    }
    
}
